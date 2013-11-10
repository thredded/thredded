module Thredded
  class PostsController < Thredded::ApplicationController
    load_and_authorize_resource only: [:index, :show]
    helper_method :messageboard, :topic, :user_topic
    before_filter :update_user_activity

    def index
      authorize! :read, topic

      @posts = topic.posts.page(current_page)
      @post  = messageboard.posts.build(topic: topic)

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
          filter: messageboard.filter,
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
      @topic ||= topic_with_eager_loaded_user_topic_reads
    end

    def topic_with_eager_loaded_user_topic_reads
      messageboard.topics.find_by_slug(params[:topic_id])
    end

    def user_topic
      @user_topic ||= UserTopicDecorator.new(current_user, topic)
    end

    def post
      @post ||= topic.posts.find(params[:id])
    end

    def current_page
      params[:page].nil? ? 1 : params[:page].to_i
    end
  end
end
