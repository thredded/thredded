# frozen_string_literal: true

Thredded::Engine.routes.draw do # rubocop:disable Metrics/BlockLength
  page_constraint = { page: /[1-9]\d*/ }

  resources :private_topics, except: %i[new show edit], path: 'private-topics' do
    member do
      get '(page-:page)', action: :show, as: '', constraints: page_constraint
    end
  end

  resources :private_posts, except: %i[index show new edit], path: 'private-posts'
  resources :messageboard_groups, only: %i[create show index update destroy], path: 'messageboard-groups'

  scope only: [:show], constraints: { id: Thredded.routes_id_constraint } do
    resources :private_post_permalinks, path: 'private-posts'
    resources :post_permalinks, path: 'posts'
  end

  resources :posts, only: %i[destroy update]

  resources :autocomplete_users, only: [:index], path: 'autocomplete-users'

  constraints(->(req) { req.env['QUERY_STRING'].include? 'q=' }) do
    get '/messageboards' => 'topics#search', as: :messageboards_search
    get '/messageboards/:messageboard_id' => 'topics#search', as: :messageboard_search
  end

  scope path: 'admin' do
    scope controller: :moderation, path: 'moderation' do
      scope constraints: page_constraint do
        get '(/page-:page)', action: :pending, as: :pending_moderation
        get '/history(/page-:page)', action: :history, as: :moderation_history
        get '/users(/page-:page)', action: :users, as: :users_moderation
        get '/users/:id(/page-:page)', action: :user, as: :user_moderation
        get '/activity(/page-:page)', action: :activity, as: :moderation_activity
      end
      post '', action: :moderate_post, as: :moderate_post
      post '/user/:id', action: :moderate_user, as: :moderate_user
    end
  end

  scope path: 'action' do
    # flat urls under here for anything which is non-visible to users & search engines (typically json actions)
    resources :posts, only: [] do
      member do
        post 'mark_as_read'
        post 'mark_as_unread'
      end
    end

    resources :private_posts, path: 'private-posts', only: [] do
      member do
        post 'mark_as_read'
        post 'mark_as_unread'
      end
    end

    resources :private_topics, path: 'private-topics', only: [] do
      collection do
        post 'mark_as_read', action: :mark_all_as_read
      end
    end

    resources :topics, only: [] do
      collection do
        post 'mark_as_read', action: :mark_all_as_read
      end
      member do
        post 'mark_as_read', action: :mark_as_read
      end
    end
    resources :messageboards, only: %i[], path: '' do
      resources :topics, only: [] do
        collection do
          post 'mark_as_read', action: :mark_all_as_read
        end
      end
    end
  end

  resources :user_details, path: 'user-details', only: [:update]

  resources :topics, only: %i[update destroy create] do
    collection do
      get 'filter-movies/(page-:page)', action: :filter_movies_by_categories, constraints: page_constraint
      get 'unread', action: :unread, as: :unread
    end
    member do
      get '(page-:page)', action: :show, as: '', constraints: page_constraint
      post 'follow', action: :follow
      post 'unfollow', action: :unfollow
      post 'increment', action: :increment
    end
  end

  resource :preferences, only: %i[update show], as: :global_preferences
  resources :messageboards, only: %i[show update destroy index create]
  resources :messageboards, only: %i[], path: '' do
    resource :preferences, only: %i[update]
    resources :topics, path: 'topics', only: [:create] do
      collection do
        get '(page-:page)', action: :index, as: '', constraints: page_constraint
        get '/unread', action: :unread, as: :unread
      end
      resources :posts, only: %i[create], path: ''
    end
  end

  resources :categories, except: %i[new edit]
  resources :badges, except: %i[new edit] do
    member do
      put 'main', action: :main
      put 'users/:user_ids', action: :assign
      delete 'users/:user_ids', action: :remove
    end
  end
  resources :news, path: 'news'do
    collection do
      get '(page-:page)', action: :index, as: '', constraints: page_constraint
    end
  end

  resources :events, path: 'events'do
    collection do
      get '(page-:page)', action: :index, as: '', constraints: page_constraint
    end
  end

get 'homepage', action: :index, controller: 'homepage'
resources :relaunch_users, except: %i[new edit update]

root to: 'messageboards#index'
end
