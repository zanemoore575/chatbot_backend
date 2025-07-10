# app/controllers/application_controller.rb

class ApplicationController < ActionController::API
  include ActionController::Live

  def chat
    # Set headers for streaming. This must be done first.
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache'

    user_message = params[:message]

    # We'll send an error over the stream if the message is blank.
    if user_message.blank?
      response.stream.write("data: [ERROR] Message cannot be empty.\n\n")
      response.stream.close
      return
    end

    client = OpenAI::Client.new

    # The `openai-ruby` gem will call this proc for each chunk of data.
    # The controller action will stay open as long as this stream is active.
    client.chat(
      parameters: {
        model: "gpt-4.1-nano",
        messages: [{ role: "user", content: user_message }],
        temperature: 0.7,
        stream: proc do |chunk, _bytesize|
          content = chunk.dig("choices", 0, "delta", "content")
          response.stream.write("data: #{content}\n\n") if content
        end
      }
    )
  # When the `client.chat` block is finished, ActionController::Live will
  # handle closing the stream automatically.
  end
end
