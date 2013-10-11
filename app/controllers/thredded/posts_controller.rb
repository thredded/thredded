module Thredded
  class PostsController < Thredded::ApplicationController
    load_and_authorize_resource only: [:index, :show]
    before_filter :ensure_topic_exists
    helper_method :messageboard, :topic, :user_topic

    def index
      logger.debug('Thredded.PostsController.index 1')
      authorize! :read, topic

      logger.debug('Thredded.PostsController.index 2')
      @posts = topic.posts.page(current_page)
      logger.debug('Thredded.PostsController.index 3')
      @post = messageboard
        .posts
        .build(topic: topic, filter: post_filter)

      logger.debug('Thredded.PostsController.index 4')
      update_read_status!(current_user, current_page) if current_user
    end

    def create
      # BERGEN: why does "authorize! :create, post"  fail when the one in update works?
      # Don't we want this to ensure nobody can create without auth?
      topic.posts.create(post_params)
      redirect_to :back
    end

    def edit
      authorize! :manage, post
    end

    def update
      # BERGEN: I put this in, Joel did not, I think we want so nobody can update without auth
      # authorize! :manage, post
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
