Rails.application.routes.draw do
  root to: 'products#index'

  resources :products, only: [:show]

  post 'quote', to: 'products#quote'
  post 'order', to: 'products#order'
  get 'done', to: 'products#done'
end
