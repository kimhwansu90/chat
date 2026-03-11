Rails.application.routes.draw do
  root "sessions#new"

  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :conversations, only: [:index, :show] do
    resources :messages, only: [:create], controller: "conversations/messages"
    member do
      post :mark_read
    end
  end

  namespace :admin do
    root to: "conversations#index"
    resources :conversations, only: [:index, :show]
    resources :users, only: [:index, :new, :create] do
      member do
        patch :update_nickname
        post :ban
        post :unban
        post :kick
      end
    end
    resources :messages, only: [:index, :destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
