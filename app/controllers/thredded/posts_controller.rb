module Thredded
  class PostsController < Thredded::ApplicationController
    load_and_authorize_resource only: [:index, :show]
    before_filter :ensure_topic_exists
    helper_method :messageboard, :topic, :user_topic

    def index
      authorize! :read, topic

      @posts = topic.posts.page(current_page)
      @post = messageboard
        .posts
        .build(topic: topic, filter: post_filter)

      update_read_status!(current_user, current_page) if current_user
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

    def update_read_status!(user, page)
      UserTopicRead.create!(
        user: user,
        topic: topic,
        farthest_post: @posts.last,
        posts_count: topic.posts_count,
        page: current_page,
      )
    end

    def topic
      @topic ||= messageboard.topics.where(slug: params[:topic_id]).first
    end

    def user_topic
      @user_topic ||= UserTopicDecorator.new(
        current_user,
        topic
      )
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

    def ensure_topic_exists
      if topic.blank?
        redirect_to default_home,
          flash: { error: 'This topic does not exist.' }
      end
    end
  end
end
