Rails.application.routes.draw do
  namespace :api do
    get :csrf, to: 'csrf#index'
    namespace :v1 do
      resources :artists, only: [:index, :show, :create, :update, :destroy]
      resources :albums, only: [:index, :show, :create, :update, :destroy]
    end
  end
end