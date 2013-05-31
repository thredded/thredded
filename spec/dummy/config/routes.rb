Rails.application.routes.draw do
  mount Thredded::Engine => '/thredded'
  get '/sessions/new' => 'sessions#new', as: :sign_in
  delete '/session' => 'sessions#destroy', as: :sign_out
  resources :sessions, only: [:new, :create, :destroy]
  root to: 'application#index'
end
