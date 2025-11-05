Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "health", to: "application#health"
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"


  scope :auth do
    post "register", to: "auth#register"
    post "login", to: "auth#login"
    post "logout", to: "auth#logout"
    post "refresh", to: "auth#refresh"
    get  "me", to: "auth#me"
  end

  resources :conversations, only:[:index, :show, :create] do
    resources :messages, only:[:index]
  end

  resources :messages, only:[:create] do
    member do
      put "read", to: "messages#mark_read"
    end
  end


  root to: proc { [200, {}, ['{"status":"ok"}']] }

end
