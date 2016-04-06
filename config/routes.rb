Thredded::Engine.routes.draw do
  resource :theme_preview, only: [:show], path: 'theme-preview' if %w(development test).include? Rails.env

  resources :private_topics, path: 'private-topics' do
    resources :private_posts, path: '', except: [:index], controller: 'posts'
  end

  resources :autocomplete_users, only: [:index], path: 'autocomplete-users'

  constraints(->(req) { req.env['QUERY_STRING'].include? 'q=' }) do
    get '/:messageboard_id(.:format)' => 'topics#search', as: :messageboard_search
  end

  get '/messageboards/new' => 'messageboards#new', as: :new_messageboard
  scope path: '/:messageboard_id' do
    get '/preferences/edit' => 'preferences#edit'
    get '/new(.:format)' => 'topics#new', as: :new_messageboard_topic
    get '/:id/edit(.:format)' => 'topics#edit', as: :edit_messageboard_topic
    get '/:id/page-:page(.:format)' => 'topics#show', as: :paged_messageboard_topic_posts, constraints: { page: /\d+/ }
    get '/category/:category_id' => 'topics#category', as: :messageboard_topics_categories
  end

  resources :messageboards, only: [:index, :create], path: '' do
    resource :preferences, only: [:edit, :update]

    resources :topics, path: '' do
      resources :posts, path: '', except: [:index]
    end
  end

  root to: 'messageboards#index'
end
