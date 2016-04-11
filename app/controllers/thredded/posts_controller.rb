module Thredded
  class PostsController < Thredded::ApplicationController
    include ActionView::RecordIdentifier

    load_and_authorize_resource only: [:index, :show, :destroy]
    helper_method :messageboard, :topic
    before_action :update_user_activity

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

    def destroy
      post.destroy!

      redirect_to request.referrer
    end

    private

    def reset_read_status
      Thredded::UserResetsPrivateTopicToUnread.new(parent_topic, thredded_current_user).run
    end

    def post_params
      p = params
            .require(:post)
            .permit(:content)
            .merge(user: thredded_current_user, ip: request.remote_ip)
      p = p.merge(messageboard: messageboard) unless for_a_private_topic?
      p
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
