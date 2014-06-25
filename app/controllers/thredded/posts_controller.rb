module Thredded
  class PostsController < Thredded::ApplicationController
    load_and_authorize_resource only: [:index, :show]
    helper_method :messageboard, :topic
    before_filter :update_user_activity

    def create
      Thredded::Post.create(post_params)
      redirect_to :back
    end

    def edit
      authorize! :edit, post
    end

    def update
      post.update_attributes(post_params.except(:user, :ip))

      redirect_to polymorphic_path([messageboard, post.postable])
    end

    def topic
      post.postable
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
          postable: parent_topic,
        )
    end

    def parent_topic
      if params[:private_topic_id]
        PrivateTopic.friendly.find(params[:private_topic_id])
      else
        Topic.friendly.find(params[:topic_id])
      end
    end

    def post
      @post ||= Thredded::Post.find(params[:id])
    end

    def current_page
      params[:page].nil? ? 1 : params[:page].to_i
    end
  end
end
