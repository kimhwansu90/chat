Rails.application.routes.draw do
  root "sessions#new"

  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # Public inquiry forms
  scope :f do
    get ":form_slug", to: "public/submissions#new", as: :public_form
    post ":form_slug", to: "public/submissions#create", as: :public_form_submit
    get ":form_slug/thank-you", to: "public/submissions#thank_you", as: :thank_you
  end

  namespace :admin do
    root to: "dashboard#index"

    resources :leads do
      member do
        patch :update_status
        post :assign
        patch :update_contract
      end
      resources :activities, only: [:create], controller: "lead_activities"
    end

    resources :forms do
      member do
        get :preview
        patch :toggle_active
      end
    end

    resources :users, only: [:index, :new, :create, :edit, :update]

    resources :nad_accounts do
      member do
        post :sync
      end
    end

    resources :nad_campaigns, only: [:index, :show]
    resources :nad_reports, only: [:index] do
      collection do
        post :fetch
      end
    end

    resources :reports, only: [:index] do
      collection do
        get :lead_report
        get :channel_report
        get :team_report
        get :roi_report
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
