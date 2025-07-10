# app/controllers/application_controller.rb

class ApplicationController < ActionController::API
  include ActionController::Live

  def chat
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache'
    sse = SSE.new(response.stream)

    # This block ensures a single database connection is used for the entire request,
    # preventing connection pool errors with streaming.
    ActiveRecord::Base.connection_pool.with_connection do
      begin
        session_id = params[:session_id]
        user_message = params[:message]
        
        # Define the AI's personality and rules here.
        system_prompt = "You are a friendly and efficient sales assistant for Custom AI Solutions. Keep your answers concise, helpful, and to the point. Your goal is to answer questions about our services quickly."

        # Load the last 10 messages to provide context to the AI.
        history = Message.where(session_id: session_id).order(created_at: :desc).limit(10).reverse.map do |msg|
          { role: msg.role, content: msg.content }
        end

        messages_to_send = [
          { role: "system", content: system_prompt }
        ] + history + [{ role: "user", content: user_message }]

        # Save the new user message to the database.
        Message.create!(session_id: session_id, role: 'user', content: user_message)

        client = OpenAI::Client.new
        full_response = ""

        client.chat(
          parameters: {
            model: "gpt-4.1-nano",
            messages: messages_to_send,
            stream: proc do |chunk, _bytesize|
              content = chunk.dig("choices", 0, "delta", "content")
              if content
                full_response += content
                sse.write(content)
              end
            end
          }
        )

        # Save the complete AI response to the database.
        Message.create!(session_id: session_id, role: 'assistant', content: full_response)

      rescue => e
        logger.error "Chat Error: #{e.message}\n#{e.backtrace.join("\n")}"
        sse.write("[ERROR] An internal error occurred.")
      ensure
        sse.write("[DONE]")
        sse.close
      end
    end
  end
end
