class MessagesController < ApplicationController
  def hello
    render json: { message: 'Hello from the chatbot backend!' }
  end
end
