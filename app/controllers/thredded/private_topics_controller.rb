module Thredded
  class PrivateTopicsController < Thredded::ApplicationController
    def index
      if cannot? :read, messageboard
        error = 'You are not authorized access to this messageboard.'
        redirect_to default_home, flash: { error: error }
      end

      @private_topics = private_topics
    end

    def new
      @private_topic = messageboard.private_topics.build
      @private_topic.posts.build

      unless can? :create, @private_topic
        error = 'Sorry, you are not authorized to post on this messageboard.'
        redirect_to messageboard_topics_url(messageboard),
          flash: { error: error }
      end
    end

    def create
      @private_topic = messageboard.private_topics.create(private_topics_params)

      redirect_to messageboard_topics_url(messageboard)
    end

    def private_topics
      PrivateTopic
        .for_messageboard(messageboard)
        .including_roles_for(current_user)
        .for_user(current_user)
        .order_by_stuck_and_updated_time
        .on_page(params[:page])
    end

    private

    def private_topics_params
      params[:topic][:user_id] << current_user.id

      params
        .require(:topic)
        .permit!
        .deep_merge!({
          user: current_user,
          last_user: current_user,
          posts_attributes: {
            '0' => {
              messageboard: messageboard,
              user: current_user,
            }
          }
        })
    end
  end
end
