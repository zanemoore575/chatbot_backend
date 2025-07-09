class MessagesController < ApplicationController
  def hello
    client = OpenAI::Client.new
    
    response = client.chat(
        parameters: {
            model: "gpt-3.5-turbo",
            messages: [{ role: "user", content: "Say 'Hello, I am an AI-powered chatbot!'" }],
            temperature: 0.7,
        })
    
    ai_message = response.dig("choices", 0, "message", "content")
    
    render json: { message: ai_message }
  end
end