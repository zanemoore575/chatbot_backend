# app/controllers/application_controller.rb

class ApplicationController < ActionController::API
  include ActionController::Live
  
  rescue_from StandardError, with: :handle_error

  def chat
    # Verify required parameters
    unless params[:session_id].present? && params[:message].present?
      return render json: { error: 'Missing required parameters' }, status: :bad_request
    end

    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache'
    response.headers['Access-Control-Allow-Origin'] = '*'
    
    sse = SSE.new(response.stream)
    session_id = params[:session_id]
    user_message = params[:message]

    begin
      # Save user message
      Message.create!(
        session_id: session_id,
        role: 'user',
        content: user_message
      )

      # Load conversation history
      history = Message.where(session_id: session_id)
                      .order(created_at: :desc)
                      .limit(10)
                      .reverse
                      .map { |msg| { role: msg.role, content: msg.content } }

      # Prepare messages for OpenAI
      messages = [
        { role: 'system', content: 'You are a helpful assistant.' },
        *history,
        { role: 'user', content: user_message }
      ]

      # Initialize OpenAI client
      client = OpenAI::Client.new
      full_response = ""

      # Stream response from OpenAI
      client.chat(
        parameters: {
          model: "gpt-4",
          messages: messages,
          stream: proc do |chunk, _bytesize|
            content = chunk.dig("choices", 0, "delta", "content")
            if content
              full_response += content
              sse.write(content)
            end
          end
        }
      )

      # Save assistant's response
      if full_response.present?
        Message.create!(
          session_id: session_id,
          role: 'assistant',
          content: full_response
        )
      end

    rescue => e
      Rails.logger.error "Chat Error: #{e.message}"
      sse.write("Error: #{e.message}")
    ensure
      sse.close
    end
  end

  private

  def handle_error(exception)
    Rails.logger.error "Application Error: #{exception.message}\n#{exception.backtrace.join("\n")}"
    render json: { error: 'An unexpected error occurred' }, status: :internal_server_error
  end
end
