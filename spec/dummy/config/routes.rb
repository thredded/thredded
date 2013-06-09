Rails.application.routes.draw do
  get '/sessions/new' => 'sessions#new', as: :sign_in
  delete '/session' => 'sessions#destroy', as: :sign_out
  resources :sessions, only: [:new, :create, :destroy]

  mount Thredded::Engine => '/thredded'
  root to: 'application#index'
end
