Rails.application.routes.draw do

  get "/index", to: "projects#home_page"

  resources :activities
  resources :instances
  resources :protocols
  resources :projects
  devise_for :users

  get "/instances/form/:id/:caseId/:activityId", to: "instances#instance_form"
  get "/instances/next/:id", to: "instances#next"

  get "/projects/tomar_decision/:activityId/:caseId", to: "projects#tomar_decision_form"
  post "/projects/resolver", to: "projects#resolver"
  get "/projectsWithAprovedProtocolsRunning", to: "projects#projectsWithAprovedProtocolsRunning"
  get "/projectWithCurrentProtocolDelayed", to: "projects#projectWithCurrentProtocolDelayed"
  get "/projectsFinishedWithAverageGreaterEqual5", to: "projects#projectsFinishedWithAverageGreaterEqual5"
  get "/incompletedArchivedProject", to: "projects#incompletedArchivedProject"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
