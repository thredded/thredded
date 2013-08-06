module Thredded
  class PostsController < ApplicationController
    include TopicsHelper
    load_and_authorize_resource only: [:index, :show]
    before_filter :ensure_topic_exists
    before_filter :pad_post, only: :create
    helper_method :messageboard, :topic

    def index
      authorize! :read, topic

      @post = messageboard.posts.build(topic: topic, filter: post_filter)
      @posts = Post.where(topic_id: topic).page(page)
      @read_status = UserTopicRead
        .find_or_create_by_user_and_topic(current_user, topic, page)

      if not_inside_topic_and_in_an_old_page?
        redirect_to_later_page and return
      else
        UserTopicRead.update_read_status!(current_user, topic, page)
      end
    end

    def create
      topic.posts.create(params[:post])
      redirect_to :back
    end

    def edit
      authorize! :update, post
    end

    def post
      post = topic.posts.find(params[:post_id])
      @post ||= post
    end

    def update
      post.update_attributes(params[:post])
      redirect_to messageboard_topic_posts_url(messageboard, topic)
    end

    private

    def post_filter
      user_messageboard_preferences.try(:filter) || :markdown
    end

    def not_inside_topic_and_in_an_old_page?
      !internal_to_topic? && page == 1 && @read_status.page > 1
    end

    def page
      params[:page].nil? ? 1 : params[:page].to_i
    end

    def extra_data
      %Q{data-latest-read=#{@read_status.post_id || 0}} if @read_status
    end

    def internal_to_topic?
      referer = request.referer || ''
      referer.include?("#{topic.id}?page=") || (!topic.slug.nil? && referer.include?("#{topic.slug}?page="))
    end

    def redirect_to_later_page
      redirect_to messageboard_topic_posts_path(messageboard, topic, page: @read_status.page)
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

    def topic
      @topic ||= messageboard.topics.find(params[:topic_id])
    end
  end
end
