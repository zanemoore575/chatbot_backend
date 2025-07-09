Rails.application.routes.draw do
  get '/hello', to: 'messages#hello'
end