module Thredded
  class PrivateTopicsController < Thredded::ApplicationController
    before_filter :ensure_messageboard_exists

    def index
      if cannot? :read, messageboard
        error = 'You are not authorized access to this messageboard.'
        redirect_to default_home, flash: { error: error }
      else
        @private_topics = get_private_topics
      end
    end

    def new
      @private_topic = messageboard.private_topics.build
      @private_topic.posts.build(
        filter: get_current_user.try(:post_filter)
      )

      unless can? :create, @private_topic
        error = 'Sorry, you are not authorized to post on this messageboard.'
        redirect_to messageboard_topics_url(messageboard),
          flash: { error: error }
      end
    end

    def create
      params[:topic][:user_id] << get_current_user.id
      merge_default_topics_params
      @private_topic = PrivateTopic.create(params[:topic])
      redirect_to messageboard_topics_url(messageboard)
    end

    def get_private_topics
      PrivateTopic
        .for_messageboard(messageboard)
        .including_roles_for(get_current_user)
        .for_user(get_current_user)
        .on_page(params[:page])
    end
  end
end
