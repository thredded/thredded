require 'thredded/setup_thredded'

Thredded::Engine.routes.draw do
  constraints(Thredded::SetupThredded.new) do
    resources :setups, path: '', only: [:new, :create]
    root to: 'setups#new'
  end

  constraints(lambda{|req| req.env['QUERY_STRING'].include? 'q=' }) do
    get '/:messageboard_id(.:format)' => 'topics#search', as: :messageboard_search
  end

  get '/:messageboard_id/new(.:format)' => 'topics#new', as: :new_messageboard_topic
  get '/:messageboard_id/:id/edit.(:format)' => 'topics#edit', as: :edit_messageboard_topic

  resources :messageboards, only: [:index], path: '' do
    resource :preferences
    resources :private_topics, only: [:new, :create, :index]

    resources :topics, except: [:show], path: '' do
      resources :posts, path: ''
    end
  end

  root to: 'messageboards#index'
end
