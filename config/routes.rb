Thredded::Engine.routes.draw do
  constraints(->(req) { req.env['QUERY_STRING'].include? 'q=' }) do
    get '/:messageboard_id(.:format)' => 'topics#search', as: :messageboard_search
  end

  resource :theme_preview, only: [:show] if %w(development test).include? Rails.env

  resources :private_topics, path: 'private-topics' do
    resources :private_posts, path: '', except: [:index], controller: 'posts'
  end

  get '/messageboards/new' => 'messageboards#new', as: :new_messageboard
  get '/:messageboard_id/preferences/edit' => 'preferences#edit'
  get '/:messageboard_id/new(.:format)' => 'topics#new', as: :new_messageboard_topic
  get '/:messageboard_id/:id/edit(.:format)' => 'topics#edit', as: :edit_messageboard_topic
  get '/:messageboard_id/:id/page-:page(.:format)' => 'topics#show', as: :paged_messageboard_topic_posts, constraints: { page: /\d+/ }
  get '/:messageboard_id/category/:category_id' => 'topics#category', as: :messageboard_topics_categories

  resources :messageboards, only: [:index, :create], path: '' do
    resource :preferences, only: [:edit, :update]

    resources :topics, path: '' do
      resources :posts, path: '', except: [:index]
    end
  end

  root to: 'messageboards#index'
end
