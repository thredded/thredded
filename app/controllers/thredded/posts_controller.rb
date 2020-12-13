# frozen_string_literal: true

module Thredded
  # A controller for managing {Post}s.
  class PostsController < Thredded::ApplicationController
    include ActionView::RecordIdentifier
    include Thredded::NewPostParams

    helper_method :topic
    before_action :assign_messageboard_for_actions, only: %i[mark_as_read mark_as_unread]
    after_action :update_user_activity

    after_action :verify_authorized

    def create
      @post_form = Thredded::PostForm.new(
        user: thredded_current_user, topic: parent_topic, post_params: new_post_params
      )
      authorize_creating @post_form.post

      if @post_form.save
        render json: PostSerializer.new(@post_form.post, include: [:user, :messageboard]).serialized_json, status: 201
      else
        render json: {errors: @post_form.errors }, status: 422
      end
    end

    def update
      authorize post, :update?

      if post.update(new_post_params)
        render json: PostSerializer.new(post, include: [:user, :messageboard]).serialized_json, status: 200
      else
        render json: {errors: post.errors }, status: 422
      end
    end

    def destroy
      authorize post, :destroy?
      post.destroy!
      head 204
    end


    def mark_as_read
      authorize post, :read?
      UserTopicReadState.touch!(thredded_current_user.id, post)
      head 204
    end

    def mark_as_unread
      authorize post, :read?
      post.mark_as_unread(thredded_current_user)
      head 204
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
      Thredded::Topic
        .where(messageboard: messageboard)
        .friendly_find!(params[:topic_id])
    end

    def assign_messageboard_for_actions
      @messageboard = post.postable.messageboard
    end

    def post
      @post ||= Thredded::Post.find!(params[:id])
    end

    def current_page
      params[:page].nil? ? 1 : params[:page].to_i
    end
  end
end
