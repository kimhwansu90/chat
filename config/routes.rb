Rails.application.routes.draw do
  root "sessions#new"

  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get    "nickname", to: "sessions#nickname_form"
  post   "nickname", to: "sessions#set_nickname"

  get "chat", to: "chat#index"

  post "messages", to: "chat#create"
  post "messages/mark_read", to: "chat#mark_read"
  post "messages/report", to: "chat#report"

  namespace :admin do
    root to: "dashboard#index"
    resources :users, only: [:index] do
      member do
        patch :update_nickname
        post :ban
        post :unban
        post :kick
      end
    end
    resources :messages, only: [:index, :destroy]
    resource :announcement, only: [:new, :create]
    resources :reports, only: [:index] do
      member do
        post :review
        post :dismiss
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
