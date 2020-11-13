Rails.application.routes.draw do
  resources :activities
  resources :instances
  resources :protocols
  resources :projects
  devise_for :users

  get "/instances/form/:id", to: "instances#instance_form"
  get "/instances/next/:id", to: "instances#next"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
