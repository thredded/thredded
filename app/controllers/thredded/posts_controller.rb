module Thredded
  class PostsController < Thredded::ApplicationController
    include ActionView::RecordIdentifier

    load_and_authorize_resource only: [:index, :show]
    helper_method :messageboard, :topic
    before_filter :update_user_activity

    def create
      post = parent_topic.posts.create!(post_params)

      reset_read_status if for_a_private_topic?
      redirect_to post_path(post)
    end

    def edit
      authorize! :edit, post
    end

    def update
      post.update_attributes(post_params.except(:user, :ip))

      redirect_to post_path(post)
    end

    def topic
      post.postable
    end

    private

    def post_path(post)
      if for_a_private_topic?
        private_topic_path(post.postable, anchor: dom_id(post))
      else
        messageboard_topic_path(messageboard, post.postable, anchor: dom_id(post))
      end
    end

    def reset_read_status
      Thredded::UserResetsPrivateTopicToUnread.new(parent_topic, current_user).run
    end

    def post_params
      params
        .require(:post)
        .permit(:content)
        .merge!(user: current_user, ip: request.remote_ip)
        .tap { |p| p.merge!(messageboard: messageboard) unless for_a_private_topic? }
    end

    def parent_topic
      if for_a_private_topic?
        PrivateTopic
          .includes(:private_users)
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
      @post ||= (for_a_private_topic? ? Thredded::PrivatePost : Thredded::Post).find(params[:id])
    end

    def current_page
      params[:page].nil? ? 1 : params[:page].to_i
    end
  end
end
