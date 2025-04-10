Rails.application.routes.draw do
  resources :events do
    resources :weddings do
      get "operator"
      post "process_photo/:total", to: "weddings#process_photo"
      resources :sessions do
        post "reupload", to: "weddings#reupload"
        post "print_qr", to: "weddings#print_qr"
        post "delete_session", to: "weddings#delete_session"
      end
    end

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
      get "gallery"
      resources :sessions do
        post "print_photo", to: "photobooths#print_photo"
        post "reupload", to: "photobooths#reupload"
        post "retry", to: "photobooths#retry"
        post "delete_session", to: "photobooths#delete_session"
        get "show_gallery", to: "photobooths#show_gallery"
      end
    end

    resources :ai_photobooths do
      get "liveview"
      get "liveview_operator"
      post "capture"
      get "select_theme"
      get "select_photo_operator"
      post "select_photo_operator/:id", to: "photobooths#select_photo_operator_id"
      post "toggle_liveview"
      post "connect"
      post "finish"
      get "finish_operator"
      get "gallery"
      resources :sessions do
        post "print_photo", to: "ai_photobooths#print_photo"
        post "print_qr", to: "ai_photobooths#print_qr"
        post "retry", to: "ai_photobooths#retry"
      end
      resources :ai_themes do
        post "pin", to: "ai_themes#pin", as: "pin"
        post "unpin", to: "ai_themes#unpin", as: "unpin"
      end
    end

    resources :videobooths do
      post "preprocess_video"
      post "increment_counter"
      post "decrement_counter"
      get "gallery"
      resources :sessions do
        post "reupload", to: "videobooths#reupload"
        post "process_video", to: "videobooths#process_video"
        post "increment_session_counter", to: "videobooths#increment_session_counter"
        post "decrement_session_counter", to: "videobooths#decrement_session_counter"
        post "print_qr", to: "videobooths#print_qr"
        post "delete_session", to: "videobooths#delete_session"
      end
    end

    resources :sessions do
    end
  end

  get "camera/live"

  # get "camera/capture"
  get "camera/preview"

  get "/", to: "roots#root"
  # resources :roots, only: [ :create ]

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
