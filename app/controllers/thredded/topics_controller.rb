module Thredded
  class TopicsController < Thredded::ApplicationController
    helper_method :current_page, :topic, :user_topic
    before_filter :update_user_activity

    def index
      authorize_reading messageboard

      @topics = topics
      @decorated_topics = Thredded::UserTopicDecorator
        .decorate_all(thredded_current_user, @topics)
      initialize_new_topic.tap do |new_topic|
        @new_topic = new_topic if current_ability.can?(:create, new_topic.topic)
      end
    end

    def show
      authorize! :read, topic

      @posts = topic.posts
        .includes(:user, :messageboard, :postable)
        .order_oldest_first
        .page(current_page)

      @new_post = messageboard.posts.build(
        postable: topic,
        filter: messageboard.filter
      )

      update_read_status
    end

    def search
      query = params[:q].to_s
      @topics = Topic.search(query, messageboard).order(updated_at: :desc).limit(50)
      @decorated_topics = Thredded::UserTopicDecorator
        .decorate_all(thredded_current_user, @topics)

      # TODO: do not use flash.now, this should be handled by the view instead.
      if @topics.present?
        flash.now[:notice] = "Search Results for '#{query}'"
      else
        flash.now[:error] =  "There are no results for your search - '#{query}'"
      end
    end

    def new
      @new_topic = TopicForm.new(messageboard: messageboard, user: thredded_current_user)
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
        .decorate_all(thredded_current_user, @topics)

      render :index
    end

    def create
      @new_topic = TopicForm.new(new_topic_params)
      authorize_creating @new_topic.topic
      if @new_topic.save
        redirect_to messageboard_topics_path(messageboard)
      else
        render :new
      end
    end

    def edit
      authorize! :update, topic
    end

    def update
      topic.update_attributes!(topic_params.merge(last_user_id: thredded_current_user.id))
      redirect_to messageboard_topic_url(messageboard, topic), flash: { notice: 'Topic updated' }
    end

    def destroy
      authorize! :destroy, topic
      topic.destroy!
      redirect_to messageboard_topics_path(messageboard), flash: { notice: 'Topic deleted' }
    end

    private

    def initialize_new_topic
      TopicForm.new(messageboard: messageboard, user: thredded_current_user)
    end

    def topic
      @topic ||= messageboard.topics.find_by_slug_with_user_topic_reads!(params[:id])
    end

    def topics
      messageboard
        .topics
        .includes(:categories, :last_user, :user)
        .order_by_stuck_and_updated_time
        .on_page(current_page)
        .load
    end

    def topic_params
      params
        .require(:topic)
        .permit(:title, :locked, :sticky, category_ids: [])
        .merge(user: thredded_current_user)
    end

    def new_topic_params
      params
        .require(:topic)
        .permit(:title, :locked, :sticky, :content, category_ids: [])
        .merge(
          messageboard: messageboard,
          user: thredded_current_user,
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

    def current_page
      params[:page] || 1
    end

    def user_topic
      @user_topic ||= UserTopicDecorator.new(thredded_current_user, topic)
    end

    def update_read_status
      return if thredded_current_user.thredded_anonymous?

      read_history = UserTopicRead.where(
        user_id: thredded_current_user,
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
