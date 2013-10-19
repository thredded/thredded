module Thredded
  class PostsController < Thredded::ApplicationController
    load_and_authorize_resource only: [:index, :show]
    helper_method :messageboard, :topic, :user_topic

    rescue_from Thredded::Errors::TopicNotFound do |exception|
      redirect_to messageboard_topics_path(messageboard),
        alert: 'This topic does not exist'
    end

    def index
      authorize! :read, topic

      @posts = topic.posts.page(current_page)
      @post  = messageboard.posts.build(topic: topic, filter: post_filter)

      update_read_status!
    end

    def create
      topic.posts.create(post_params)
      redirect_to :back
    end

    def edit
      authorize! :manage, post
    end

    def update
      post.update_attributes(post_params)
      redirect_to messageboard_topic_posts_url(messageboard, topic)
    end

    private

    def post_params
      params
        .require(:post)
        .permit!
        .merge!(
          ip: request.remote_ip,
          user: current_user,
          messageboard: messageboard,
        )
    end

    def update_read_status!
      if current_user
        read_history = UserTopicRead.where(
          user: current_user,
          topic: topic,
        ).first_or_initialize

        read_history.update_attributes(
          farthest_post: @posts.last,
          posts_count: topic.posts_count,
          page: current_page,
        )
      end
    end

    def topic
      @topic ||= messageboard.topics.find_by_slug(params[:topic_id])
    end

    def user_topic
      @user_topic ||= UserTopicDecorator.new(current_user, topic)
    end

    def post
      @post ||= topic.posts.find(params[:id])
    end

    def post_filter
      user_messageboard_preferences.try(:filter) || :markdown
    end

    def current_page
      params[:page].nil? ? 1 : params[:page].to_i
    end
  end
end
