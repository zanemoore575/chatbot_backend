# app/controllers/application_controller.rb

class ApplicationController < ActionController::API
  include ActionController::Live

  def chat
    # Set headers for Server-Sent Events (SSE)
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache'
    
    # Using ActionController::Live::SSE is a cleaner way to write to the stream
    sse = SSE.new(response.stream)

    begin
      user_message = params[:message]
      client = OpenAI::Client.new

      # Add a system message here to define the chatbot's role
      system_prompt = "You are a helpful assistant." 

      client.chat(
        parameters: {
          model: "gpt-4.1-nano", # Or your preferred model
          messages: [
            { role: "system", content: system_prompt },
            { role: "user", content: user_message }
          ],
          stream: proc do |chunk, _bytesize|
            # Extract the content from the streaming chunk
            content = chunk.dig("choices", 0, "delta", "content")
            # Write the content to the stream if it exists
            sse.write(content) if content
          end
        }
      )
    rescue IOError
      # This error can happen if the client disconnects.
      # It's safe to ignore.
    ensure
      # IMPORTANT: Send a special [DONE] message so the frontend knows to close the connection.
      sse.write("[DONE]")
      # Close the stream.
      sse.close
    end
  end
end
