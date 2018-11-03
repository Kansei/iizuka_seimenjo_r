Rails.application.routes.draw do
  devise_for :users
  root to: 'orders#index'
  resources :menus, except: [:show]
  resources :orders, except: [:show] do
    collection do
      post 'confirm'
      get 'recive'
    end
  end

  get '*path', to: 'application#render_404'
end
