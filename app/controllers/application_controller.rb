# app/controllers/application_controller.rb

class ApplicationController < ActionController::API
  # Include the module that allows for streaming
  include ActionController::Live

  def chat
    user_message = params[:message]

    if user_message.blank?
      render json: { error: "Message parameter is missing" }, status: :bad_request
      return
    end

    # Set the headers for a streaming response
    response.headers['Content-Type'] = 'text/event-stream'
    # The 'Cache-Control' header is important to prevent buffering by proxies
    response.headers['Cache-Control'] = 'no-cache'

    client = OpenAI::Client.new

    begin
      # Use a block with `stream: proc` to handle incoming data chunks
      client.chat(
        parameters: {
          model: "gpt-4.1-nano",
          messages: [{ role: "user", content: user_message }],
          temperature: 0.7,
          # This is the key part for streaming
          stream: proc do |chunk, _bytesize|
            # Each 'chunk' is a piece of the response from OpenAI
            content = chunk.dig("choices", 0, "delta", "content")
            
            # Write each piece of content to the response stream as it arrives
            # The "data: " prefix is required for Server-Sent Events (SSE)
            response.stream.write("data: #{content}\n\n") if content
          end
        }
      )
    rescue => e
      # Log any errors that occur during the API call
      logger.error "OpenAI API streaming error: #{e.message}"
      response.stream.write("data: [ERROR]\n\n")
    ensure
      # Always close the stream when you're done
      response.stream.close
    end
  end
end
