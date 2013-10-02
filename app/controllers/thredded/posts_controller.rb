module Thredded
  class PostsController < ApplicationController
    load_and_authorize_resource only: [:index, :show]
    before_filter :ensure_topic_exists
    before_filter :pad_post, only: :create
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
      topic.posts.create(params[:post])
      redirect_to :back
    end

    def edit
      authorize! :manage, post
    end

    def update
      post.update_attributes(params[:post])
      redirect_to messageboard_topic_posts_url(messageboard, topic)
    end

    private

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
      @topic ||= messageboard.topics.find(params[:topic_id])
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

    def pad_post
      params[:post][:ip] = request.remote_ip
      params[:post][:user] = current_user
      params[:post][:messageboard] = messageboard
    end

    def ensure_topic_exists
      if topic.blank?
        redirect_to default_home,
          flash: { error: 'This topic does not exist.' }
      end
    end
  end
end
