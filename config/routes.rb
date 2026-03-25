Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[ new create ]
  resource :account, only: %i[ edit update destroy ]
  resource :password_change, only: %i[ update ], path: "account/password"

  resources :recipes do
    collection do
      resource :import, only: %i[ new create ], module: :recipes, as: :recipe_import
    end
    resource :favourite, only: %i[ create destroy ], module: :recipes
    resource :duplicate, only: %i[ create ], module: :recipes
  end
  resources :tags, only: %i[ index update destroy ]

  resource :plan, only: %i[ show ] do
    post :copy_previous_week
    delete :clear
  end
  resources :meal_plan_entries, only: %i[ create update destroy ], path: "plan/entries"

  resource :grocery_list, only: %i[ show ], path: "groceries"
  resource :grocery_check, only: %i[ create destroy ], path: "groceries/check"
  resources :grocery_extras, only: %i[ create update destroy ], path: "groceries/extras"
  resources :pantry_items, except: %i[ show ], path: "pantry"

  # Liveness and database check for docker and uptime monitors.
  get "up" => "health#show", as: :health_check

  root "dashboard#show"
end
