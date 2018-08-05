Rails.application.routes.draw do
  resources :menus, except: [:show]
end
