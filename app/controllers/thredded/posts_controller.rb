module Thredded
  class PostsController < Thredded::ApplicationController
    load_and_authorize_resource only: [:index, :show]
    helper_method :messageboard, :topic
    before_filter :update_user_activity

    def create
      Thredded::Post.create(post_params)

      ensure_role_exists
      reset_read_status if for_a_private_topic?
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

    def ensure_role_exists
      EnsureRoleExistsJob
        .queue
        .for_user_and_messageboard(current_user.id, messageboard.id)
    end

    def reset_read_status
      Thredded::UserResetsPrivateTopicToUnread.new(parent_topic, current_user).run
    end

    def post_params
      params
        .require(:post)
        .permit(:content)
        .merge!(
          ip: request.remote_ip,
          user: current_user,
          messageboard: messageboard,
          filter: messageboard.filter,
          postable: parent_topic,
        )
    end

    def parent_topic
      if for_a_private_topic?
        PrivateTopic
          .includes(:private_users)
          .where(messageboard: messageboard)
          .friendly
          .find(params[:private_topic_id])
      else
        Topic
          .where(messageboard: messageboard)
          .friendly
          .find(params[:topic_id])
      end
    end

    def for_a_private_topic?
      params[:private_topic_id].present?
    end

    def post
      @post ||= Thredded::Post.find(params[:id])
    end

    def current_page
      params[:page].nil? ? 1 : params[:page].to_i
    end
  end
end
