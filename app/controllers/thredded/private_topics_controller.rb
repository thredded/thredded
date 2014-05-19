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
      @private_topic = PrivateTopicForm.new(messageboard: messageboard)
      authorize_creating @private_topic.private_topic
    end

    def create
      @private_topic = PrivateTopicForm.new(new_private_topic_params)
      @private_topic.save
      redirect_to messageboard_topics_url(messageboard)
    end

    def private_topics
      PrivateTopic
        .for_messageboard(messageboard)
        .including_roles_for(current_user)
        .for_user(current_user)
        .order('updated_at DESC')
        .on_page(params[:page])
    end

    private

    def new_private_topic_params
      params
        .require(:private_topic)
        .permit(:title, :locked, :sticky, :content, user_ids: [], category_ids: [])
        .merge(
          messageboard: messageboard,
          user: current_user,
          ip: request.remote_ip,
        )
    end
  end
end
