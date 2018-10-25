Rails.application.routes.draw do
  devise_for :users
  resources :menus, except: [:show]
  resources :orders do
    collection do
      post 'confirm'
      get 'recive'
    end
  end
end
