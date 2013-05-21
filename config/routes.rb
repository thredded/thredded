Thredded::Engine.routes.draw do
  constraints(lambda{|req| req.env['QUERY_STRING'].include? 'q=' }) do
    get '/:messageboard_id(.:format)' => 'topics#search', as: :messageboard_search
  end

  get '/:messageboard_id' => 'topics#index', as: :messageboard_topics
  get '/:messageboard_id/topics/new/(:type)' => 'topics#new', as: :new_messageboard_topic
  get '/:messageboard_id/topics/category/:category_id' => 'topics#by_category', as: :messageboard_topics_by_category
  get '/:messageboard_id/:topic_id/edit(.:format)' => 'topics#edit', as: :edit_messageboard_topic
  put '/:messageboard_id/:topic_id(.:format)' => 'topics#update', as: :messageboard_topic
  post '/:messageboard_id/topics(.:format)' => 'topics#create', as: :create_messageboard_topic

  get '/:messageboard_id/private_topics/new/(:type)' => 'private_topics#new', as: :new_messageboard_private_topic
  get '/:messageboard_id/:topic_id(.:format)' => 'posts#index', as: :messageboard_topic_posts
  get '/:messageboard_id/:topic_id/posts(.:format)' => 'posts#index'
  get '/:messageboard_id/:topic_id/:post_id(.:format)' => 'posts#show', as: :messageboard_topic_post
  get '/:messageboard_id/:topic_id/:post_id/edit(.:format)' => 'posts#edit', as: :edit_messageboard_topic_post
  put '/:messageboard_id/:topic_id/:post_id(.:format)' => 'posts#update'
  post '/:messageboard_id/private_topics(.:format)' => 'private_topics#create', as: :create_messageboard_private_topic
  post '/:messageboard_id/:topic_id/posts(.:format)' => 'posts#create', as: :create_messageboard_topic_post

  resources :messageboards do
    resources :topics do
      resources :posts
    end
  end

  root to: 'messageboards#index'
end
