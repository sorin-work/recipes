Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[ new create ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :recipes do
    collection do
      resource :import, only: %i[ new create ], module: :recipes, as: :recipe_import
    end
    resource :favourite, only: %i[ create destroy ], module: :recipes
    resource :duplicate, only: %i[ create ], module: :recipes
  end
  resources :meal_plan_entries, only: %i[ create update destroy ], path: "plan/entries"

  root "recipes#index"
end
