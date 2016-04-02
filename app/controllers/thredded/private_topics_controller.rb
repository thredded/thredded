module Thredded
  class PrivateTopicsController < Thredded::ApplicationController
    helper_method :private_topic

    def index
      @new_private_topic = PrivateTopicForm.new(user: thredded_current_user)
      @private_topics = PrivateTopic
                          .uniq
                          .for_user(thredded_current_user)
                          .order('updated_at DESC')
                          .on_page(params[:page])
                          .load
      @decorated_private_topics = Thredded::UserPrivateTopicDecorator
        .decorate_all(thredded_current_user, @private_topics)
    end

    def show
      authorize! :read, private_topic
      UserReadsPrivateTopic.new(private_topic, thredded_current_user).run

      @posts = private_topic
        .posts
        .includes(:user)
        .order('id ASC')

      @post = private_topic.posts.build
    end

    def new
      @private_topic = PrivateTopicForm.new(user: thredded_current_user)
      authorize_creating @private_topic.private_topic
    end

    def create
      @private_topic = PrivateTopicForm.new(new_private_topic_params)
      if @private_topic.save
        NotifyPrivateTopicUsersJob
          .perform_later(@private_topic.private_topic.id)

        UserResetsPrivateTopicToUnread
          .new(@private_topic.private_topic, thredded_current_user)
          .run

        redirect_to @private_topic.private_topic
      else
        render :new
      end
    end

    private

    def private_topic
      @private_topic ||= Thredded::PrivateTopic.find_by_slug(params[:id])
    end

    def new_private_topic_params
      params
        .require(:private_topic)
        .permit(:title, :locked, :sticky, :content, user_ids: [], category_ids: [])
        .merge(
          user: thredded_current_user,
          ip: request.remote_ip)
    end
  end
end
