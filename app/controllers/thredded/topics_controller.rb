module Thredded
  class TopicsController < Thredded::ApplicationController
    helper_method :topic, :topics

    def index
      authorize_reading messageboard

      @topics = Thredded::TopicsViewModel.new(params)
    end

    def show
      authorize! :read, topic

      @posts = topic.posts
        .includes(:user, :messageboard, :postable)
        .order('id ASC')
        .page(current_page)

      @post  = messageboard.posts.build(
        postable: topic,
        filter: messageboard.filter
      )
    end

    def search
      @topics = Topic.search(params[:q], messageboard)
      @decorated_topics = Thredded::UserTopicDecorator
        .decorate_all(current_user, @topics)
    end

    def new
      @new_topic = TopicForm.new(messageboard: messageboard)
      authorize_creating @new_topic.topic
    end

    def category
      @category = messageboard.categories.friendly.find(params[:category_id])
      @topics = @category
        .topics
        .unstuck
        .order_by_updated_time
        .on_page(current_page)
        .load
      @decorated_topics = Thredded::UserTopicDecorator
        .decorate_all(current_user, @topics)

      render :index
    end

    def create
      @new_topic = TopicForm.new(new_topic_params)
      @new_topic.save

      ensure_role_exists
      redirect_to messageboard_topics_path(messageboard)
    end

    def edit
      authorize! :update, topic
    end

    def update
      topic.update_attributes!(topic_params.merge(last_user_id: current_user.id))
      redirect_to messageboard_topic_posts_url(messageboard, topic)
    end

    private

    def ensure_role_exists
      EnsureRoleExistsJob
        .queue
        .for_user_and_messageboard(current_user.id, messageboard.id)
    end

    def topic
      @topic ||= messageboard.topics.find_by_slug_with_user_topic_reads!(params[:id])
    end

    def topic_params
      params
        .require(:topic)
        .permit(:title, :locked, :sticky, category_ids: [])
        .merge(user: current_user)
    end

    def new_topic_params
      params
        .require(:topic)
        .permit(:title, :locked, :sticky, :content, category_ids: [])
        .merge(
          messageboard: messageboard,
          user: current_user,
          ip: request.remote_ip,
        )
    end

    def topics_by_category(category_id)
      messageboard.categories.friendly.find(category_id)
        .topics
        .unstuck
        .order_by_updated
        .on_page(current_page)
        .load
    end

    def user_topic
      @user_topic ||= UserTopicDecorator.new(current_user, topic)
    end
  end
end
