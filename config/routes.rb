Rails.application.routes.draw do
  resources :menus, except: [:show]
  resources :orders do
    collection do
      post 'confirm'
    end
  end
end
