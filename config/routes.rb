# frozen_string_literal: true
Thredded::Engine.routes.draw do
  resource :theme_preview, only: [:show], path: 'theme-preview' if %w(development test).include? Rails.env

  positive_int = /[1-9]\d*/
  page_constraint = { page: positive_int }

  scope path: 'private-topics' do
    resource :private_topic, only: [:new], path: ''
    resources :private_topics, except: [:new, :show], path: '' do
      member do
        get '(page-:page)', action: :show, as: '', constraints: page_constraint
      end
      resources :private_posts, path: '', except: [:index, :show], controller: 'posts'
    end
  end

  scope only: [:show], constraints: { id: positive_int } do
    resources :private_post_permalinks, path: 'private-posts'
    resources :post_permalinks, path: 'posts'
  end

  resources :autocomplete_users, only: [:index], path: 'autocomplete-users'

  constraints(->(req) { req.env['QUERY_STRING'].include? 'q=' }) do
    get '/' => 'topics#search', as: :messageboards_search
    get '/:messageboard_id(.:format)' => 'topics#search', as: :messageboard_search
  end

  scope path: 'admin' do
    resources :messageboard_groups, only: [:new, :create]
    scope controller: :moderation, path: 'moderation' do
      scope constraints: page_constraint do
        get '(/page-:page)', action: :pending, as: :pending_moderation
        get '/history(/page-:page)', action: :history, as: :moderation_history
        get '/users(/page-:page)', action: :users, as: :users_moderation
        get '/users/:id(/page-:page)', action: :user, as: :user_moderation
      end
      post '', action: :moderate_post, as: :moderate_post
      post '/user/:id', action: :moderate_user, as: :moderate_user
    end
  end

  resource :preferences, only: [:edit, :update]
  resource :messageboard, path: 'messageboards', only: [:new]
  resources :messageboards, only: [:edit, :update]
  resources :messageboards, only: [:index, :create], path: '' do
    resource :preferences, only: [:edit, :update]
    resource :topic, path: 'topics', only: [:new]
    resources :topics, path: '', except: [:index, :new, :show] do
      collection do
        get '(page-:page)', action: :index, as: '', constraints: page_constraint
        get '/category/:category_id', action: :category, as: :categories
      end
      member do
        get '(page-:page)', action: :show, as: '', constraints: page_constraint
        post 'follow'
        post 'unfollow'
      end
      resources :posts, except: [:index, :show], path: ''
    end
  end

  root to: 'messageboards#index'
end
