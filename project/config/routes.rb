Rails.application.routes.draw do
  resources :reports, :only => [:index, :update, :destroy]
  resources :song_types, :except => [:show]
  root "songs#index"

  resources :manipulators, :only => [:index, :update, :destroy] do
    collection do
      get 'user_login'
      get 'manager_login'
      post 'do_login'
      get 'logout'
      get 'user_register'
      get 'manager_register'
      post 'do_register'
      get 'my_page/:id', to: 'manipulators#my_page', as: 'my_page'
    end
  end

  resources :manipulators, :only => [:my_page] do
    resources :notices, :only => [:destroy]
  end

  resources :songs do
    resources :comments, :only => [:create, :destroy] do
      resources :reports, :only => [:create]
      # member do
      #   post '/report', to: "reports#create"
      # end
    end
    resources :pictures, :only => [:create, :destroy]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
