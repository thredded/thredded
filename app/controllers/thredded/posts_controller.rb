# frozen_string_literal: true
module Thredded
  class PostsController < Thredded::ApplicationController
    include ActionView::RecordIdentifier

    helper_method :topic
    before_action :update_user_activity

    after_action :verify_authorized

    def create
      post = parent_topic.posts.build(post_params)
      authorize_creating post
      post.save!

      redirect_to post_path(post, user: thredded_current_user)
    end

    def edit
      authorize post, :update?
    end

    def update
      authorize post, :update?
      post.update_attributes(post_params.except(:user, :ip))

      redirect_to post_path(post, user: thredded_current_user)
    end

    def destroy
      authorize post, :destroy?
      post.destroy!

      redirect_back fallback_location: topic_url(topic),
                    notice: I18n.t('thredded.posts.deleted_notice')
    end

    private

    def topic
      post.postable
    end

    def post_params
      p = params.require(:post)
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
