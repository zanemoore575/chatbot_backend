# config/routes.rb

Rails.application.routes.draw do
  # Defines the route for the chat functionality.
  # We use a GET request here because the browser's EventSource API,
  # used for streaming, can only make GET requests.
  get '/chat', to: 'application#chat'

  # You can define other routes for your application here.
end
