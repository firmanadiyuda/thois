Rails.application.routes.draw do
  resources :events do
    resources :photobooths do
      get "liveview"
      get "liveview_operator"
      post "capture"
      get "select_photo"
      get "select_photo_operator"
      post "select_photo_operator/:id", to: "photobooths#select_photo_operator_id"
      post "toggle_liveview"
      post "connect"
      post "finish"
      get "finish_operator"
      # get "/print_photo/:session_id", to: "photobooths#print"
      resources :sessions do
        post "print_photo", to: "photobooths#print_photo"
        post "retry", to: "photobooths#retry"
      end
    end


    resources :videobooths
    resources :sessions do
      # resources :export
    end


    # resources :videobooth_sessions
  end

  get "camera/live"

  # get "camera/capture"
  get "camera/preview"

  get "/tes", to: "roots#tes"
  resources :roots, only: [ :create ]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "root#index"
end
