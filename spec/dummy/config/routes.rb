Rails.application.routes.draw do
  root to: 'application#index'

  get '/sessions/new' => 'sessions#new'
  get '/session' => 'sessions#destroy'
  resources :sessions, only: [:new, :create, :destroy]

  mount Thredded::Engine => '/forum'
end
