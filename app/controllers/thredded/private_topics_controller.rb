module Thredded
  class PrivateTopicsController < Thredded::ApplicationController
    helper_method :private_topic

    def index
      if cannot? :read, messageboard
        error = 'You are not authorized access to this messageboard.'
        redirect_to default_home, flash: { error: error }
      end

      @private_topics = private_topics
      @decorated_private_topics = Thredded::UserPrivateTopicDecorator
        .decorate_all(current_user, @private_topics)
    end

    def show
      authorize! :read, private_topic
      UserReadsPrivateTopic.new(private_topic, current_user).run

      @posts = private_topic
        .posts
        .includes(:user, :messageboard, :attachments)
        .order('id ASC')

      @post = messageboard.posts.build(postable: private_topic)
    end

    def new
      @private_topic = PrivateTopicForm.new(messageboard: messageboard)
      authorize_creating @private_topic.private_topic
    end

    def create
      @private_topic = PrivateTopicForm.new(new_private_topic_params)
      @private_topic.save

      UserResetsPrivateTopicToUnread
        .new(@private_topic.private_topic, current_user)
        .run

      redirect_to [messageboard, @private_topic.private_topic]
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

    def private_topic
      @private_topic ||= messageboard.private_topics.find_by_slug(params[:id])
    end

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
