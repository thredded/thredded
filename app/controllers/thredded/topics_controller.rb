module Thredded
  class TopicsController < Thredded::ApplicationController
    helper_method :current_page, :topic, :user_topic
    before_filter :update_user_activity

    def index
      authorize_reading messageboard

      @topics = topics
      @decorated_topics = Thredded::UserTopicDecorator
        .decorate_all(current_user, @topics)
    end

    def show
      authorize! :read, topic

      @posts = topic.posts
        .includes(:user, :messageboard, :attachments)
        .order('id ASC')
        .page(current_page)

      @post  = messageboard.posts.build(
        postable: topic,
        filter: messageboard.filter
      )

      update_read_status!
    end

    def search
      @topics = Topic.search(params[:q], messageboard)
    end

    def new
      @new_topic = TopicForm.new(messageboard: messageboard)
      authorize_creating @new_topic.topic
    end

    def by_category
      @topics = topics_by_category(params[:category_id])
      @category_name = Category.find(params[:category_id]).name
    end

    def create
      @new_topic = TopicForm.new(new_topic_params)
      @new_topic.save
      redirect_to messageboard_topics_path(messageboard)
    end

    def edit
      authorize! :update, topic
    end

    def update
      topic.update_attributes(topic_params)
      redirect_to messageboard_topic_posts_url(messageboard, topic)
    end

    private

    def topic
      @topic ||= messageboard.topics.find_by_slug(params[:id])
    end

    def topics
      Topic
        .for_messageboard(messageboard)
        .includes(:user_topic_reads, :categories, :messageboard, :last_user, :user)
        .order_by_stuck_and_updated_time
        .on_page(current_page)
        .load
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
      Category.find(category_id)
        .topics
        .unstuck
        .for_messageboard(messageboard)
        .order_by_updated
        .on_page(current_page)
    end

    def current_page
      params[:page] || 1
    end

    def user_topic
      @user_topic ||= UserTopicDecorator.new(current_user, topic)
    end

    def update_read_status!
      return if current_user.anonymous?

      read_history = UserTopicRead.where(
        user_id: current_user,
        topic: topic,
      ).first_or_initialize

      read_history.update_attributes(
        farthest_post: @posts.last,
        posts_count: topic.posts_count,
        page: current_page,
      )
    end
  end
end
