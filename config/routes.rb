require 'thredded/setup_thredded'

Thredded::Engine.routes.draw do
  constraints(Thredded::SetupThredded.new) do
    resources :setups, path: '', only: [:new, :create]
    root to: 'setups#new'
  end

  constraints(->(req) { req.env['QUERY_STRING'].include? 'q=' }) do
    get '/:messageboard_id(.:format)' => 'topics#search', as: :messageboard_search
  end

  get '/:messageboard_id/preferences/edit' => 'preferences#edit'
  get '/:messageboard_id/new(.:format)' => 'topics#new', as: :new_messageboard_topic
  get '/:messageboard_id/:id/edit(.:format)' => 'topics#edit', as: :edit_messageboard_topic
  get '/:messageboard_id/:id/page-:page(.:format)' => 'topics#show', as: :paged_messageboard_topic_posts, constraints: { page: /\d+/ }

  resources :messageboards, only: [:index], path: '' do
    resource :preferences, only: [:edit, :update]
    resources :private_topics, path: 'private' do
      resources :posts, path: '', except: [:index]
    end

    resources :topics, path: '' do
      resources :posts, path: '', except: [:index]
    end
  end
end
