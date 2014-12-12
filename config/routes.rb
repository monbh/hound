Houndapp::Application.routes.draw do
  mount Resque::Server, at: "/queue"

  get "/auth/github/callback", to: "sessions#create"
  get "/sign_out", to: "sessions#destroy"
  get "/configuration", to: "application#configuration"

  get "/faq", to: "pages#show", id: "faq"
  get "/style-guides", to: "pages#show", id: "style-guides"

  resource :account, only: [:show]
  resources :builds, only: [:create]
  resources :owners, only: [] do
    resources :style_guides, only: [:show, :update]
  end

  resources :repos, only: [:index] do
    resource :activation, only: [:create]
    resource :deactivation, only: [:create]
    resource :subscription, only: [:create, :destroy]
  end

  resources :repo_syncs, only: [:index, :create]
  resource :user, only: [:show]

  root to: "home#index"
end
