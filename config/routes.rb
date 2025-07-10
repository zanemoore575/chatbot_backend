Rails.application.routes.draw do
  # Defines the route for the chat functionality.
  # A POST request to /chat will be handled by the 'chat' action
  # in the 'application' controller.
  post '/chat', to: 'application#chat'

  # You can define other routes for your application here.
  # For example, a root route:
  # root "articles#index"
end