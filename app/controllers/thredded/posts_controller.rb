module Thredded
  class PostsController < Thredded::ApplicationController
    load_and_authorize_resource only: [:index, :show]
    helper_method :messageboard, :topic
    before_filter :update_user_activity

    def create
      topic.posts.create(post_params)
      redirect_to :back
    end

    def edit
      authorize! :edit, post
    end

    def update
      post.update_attributes(post_params.except(:user, :ip))

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


    def topic
      @topic ||= topic_with_eager_loaded_user_topic_reads
    end

    def topic_with_eager_loaded_user_topic_reads
      messageboard.topics.find_by_slug(params[:topic_id])
    end

    def post
      @post ||= topic.posts.find(params[:id])
    end

    def current_page
      params[:page].nil? ? 1 : params[:page].to_i
    end
  end
end
