Thredded::Engine.routes.draw do
  resource :theme_preview, only: [:show], path: 'theme-preview' if %w(development test).include? Rails.env

  page_constraint = { page: /[1-9]\d*/ }

  scope path: 'private-topics' do
    resource :private_topic, only: [:new], path: ''
    resources :private_topics, except: [:new, :show], path: '' do
      member do
        get '(page-:page)', action: :show, as: '', constraints: page_constraint
      end
      resources :private_posts, path: '', except: [:index, :show], controller: 'posts'
    end
  end

  resources :autocomplete_users, only: [:index], path: 'autocomplete-users'

  constraints(->(req) { req.env['QUERY_STRING'].include? 'q=' }) do
    get '/:messageboard_id(.:format)' => 'topics#search', as: :messageboard_search
  end

  resource :preferences, only: [:edit, :update]
  resource :messageboard, path: 'messageboards', only: [:new]
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
      end
      resources :posts, except: [:index, :show], path: ''
    end
  end

  root to: 'messageboards#index'
end
