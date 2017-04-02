# frozen_string_literal: true
module Thredded
  # A controller for managing {PrivatePost}s.
  class PrivatePostsController < Thredded::ApplicationController
    include ActionView::RecordIdentifier

    helper_method :topic
    after_action :update_user_activity

    after_action :verify_authorized

    def create
      post = parent_topic.posts.build(post_params)
      authorize_creating post
      post.save!

      redirect_to post_path(post, user: thredded_current_user)
    end

    def edit
      authorize post, :update?
      return redirect_to(canonical_topic_params) unless params_match?(canonical_topic_params)
      render
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

    def mark_as_unread
      authorize post, :read?
      page = post.page
      post.mark_as_unread(thredded_current_user, page)
      after_mark_as_unread # customization hook
    end

    private

    def canonical_topic_params
      { private_topic_id: topic.slug }
    end

    def after_mark_as_unread
      redirect_to private_topics_path
    end

    def topic
      post.postable
    end

    def post_params
      params.require(:post)
        .permit(:content)
        .merge(user: thredded_current_user, ip: request.remote_ip)
    end

    def parent_topic
      PrivateTopic
        .includes(:private_users)
        .friendly
        .find(params[:private_topic_id])
    end

    def post
      @post ||= Thredded::PrivatePost.find(params[:id])
    end

    def current_page
      params[:page].nil? ? 1 : params[:page].to_i
    end
  end
end
