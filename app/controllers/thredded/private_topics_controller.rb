module Thredded
  class PrivateTopicsController < ApplicationController
    before_filter :ensure_messageboard_exists

    def new
      @private_topic = messageboard.private_topics.build
      @private_topic.posts.build(
        filter: current_user.try(:post_filter)
      )

      unless can? :create, @private_topic
        error = 'Sorry, you are not authorized to post on this messageboard.'
        redirect_to messageboard_topics_url(messageboard),
          flash: { error: error }
      end
    end

    def create
      params[:topic][:user_id] << current_user.id
      merge_default_topics_params
      @private_topic = PrivateTopic.create(params[:topic])
      redirect_to messageboard_topics_url(messageboard)
    end
  end
end
