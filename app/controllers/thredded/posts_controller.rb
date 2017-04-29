# frozen_string_literal: true
module Thredded
  # A controller for managing {Post}s.
  class PostsController < Thredded::ApplicationController
    include ActionView::RecordIdentifier
    include Thredded::NewPostParams

    helper_method :topic
    after_action :update_user_activity

    after_action :verify_authorized

    def new
      @post_form = PostForm.new(user: thredded_current_user, topic: parent_topic, post_params: new_post_params)
      authorize_creating @post_form.post
    end

    def create
      @post_form = PostForm.new(user: thredded_current_user, topic: parent_topic, post_params: new_post_params)
      authorize_creating @post_form.post

      if @post_form.save
        redirect_to post_path(@post_form.post, user: thredded_current_user)
      else
        render :new
      end
    end

    def edit
      @post_form = PostForm.for_persisted(post)
      authorize @post_form.post, :update?
      return redirect_to(canonical_topic_params) unless params_match?(canonical_topic_params)
      render
    end

    def update
      authorize post, :update?
      post.update_attributes(new_post_params)

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
      page = post.page(user: thredded_current_user)
      post.mark_as_unread(thredded_current_user, page)
      after_mark_as_unread # customization hook
    end

    private

    def canonical_topic_params
      { messageboard_id: messageboard.slug, topic_id: topic.slug }
    end

    def after_mark_as_unread
      redirect_to messageboard_topics_path(messageboard)
    end

    def topic
      post.postable
    end

    def parent_topic
      Topic
        .where(messageboard: messageboard)
        .friendly
        .find(params[:topic_id])
    end

    def post
      @post ||= Thredded::Post.find(params[:id])
    end

    def current_page
      params[:page].nil? ? 1 : params[:page].to_i
    end
  end
end
