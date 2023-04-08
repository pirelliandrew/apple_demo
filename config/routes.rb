Rails.application.routes.draw do
  get '/weather', to: 'weather#index'
end
