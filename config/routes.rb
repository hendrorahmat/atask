Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout
  resources :transactions, only: [:create, :index]
end
