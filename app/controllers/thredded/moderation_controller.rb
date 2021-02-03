# frozen_string_literal: true

module Thredded
  class ModerationController < Thredded::ApplicationController
    before_action :thredded_require_login!
    before_action :thredded_require_moderator!

    def pending
      @posts = Thredded::PostsPageView.new(
        thredded_current_user,
        preload_posts_for_moderation(moderatable_posts.pending_moderation).order_oldest_first
          .send(Kaminari.config.page_method_name, current_page)
          .preload_first_topic_post
      )
      render json: PostViewSerializer.new(@posts.post_views, include: [:post, :'post.user']).serializable_hash.to_json, status: 200
    end

    def history
      @post_moderation_records = accessible_post_moderation_records
        .order(created_at: :desc)
        .send(Kaminari.config.page_method_name, current_page)
        .preload(:messageboard, :post_user, :moderator, post: :postable)
        .preload_first_topic_post
      render json: PostModerationRecordSerializer.new(@post_moderation_records, include: [:post, :messageboard, :moderator, :post_user]).serializable_hash.to_json, status: 200
    end

    def activity
      @posts = Thredded::PostsPageView.new(
        thredded_current_user,
        preload_posts_for_moderation(moderatable_posts).order_newest_first
          .send(Kaminari.config.page_method_name, current_page)
          .preload_first_topic_post
      )
      render json: PostViewSerializer.new(@posts.post_views, include: [:post, :'post.user']).serializable_hash.to_json, status: 200
    end

    def moderate_post
      moderation_state = params[:moderation_state].to_s
      return head(:bad_request) unless Thredded::Post.moderation_states.include?(moderation_state)
      post = Post.find!(params[:id].to_s)
      if post.moderation_state != moderation_state and moderatable_posts.find(params[:id].to_s)
        Thredded::ModeratePost.run!(
          post: post,
          moderation_state: moderation_state,
          moderator: thredded_current_user,
        )
        head 204
      else
        render json: {errors: "Post was already #{moderation_state}" }, status: 422
      end
    end

    def users
      @users = Thredded.user_class
        .eager_load(:thredded_user_detail)
        .merge(
          Thredded::UserDetail.order(
            Arel.sql('COALESCE(thredded_user_details.moderation_state, 0) ASC,'\
                     'thredded_user_details.moderation_state_changed_at DESC')
          )
        )
      @query = params[:q].to_s
      @users = DbTextSearch::CaseInsensitive.new(@users, Thredded.user_name_column).prefix(@query) if @query.present?
      @users = @users.send(Kaminari.config.page_method_name, current_page)
      render json: UserSerializer.new(@users, include: [:thredded_user_detail]).serializable_hash.to_json, status: 200
    end

    def user
      @user = find_user(params[:id])
      # Do not apply policy_scope here, as we want to show blocked posts as well.
      posts_scope = @user.thredded_posts
        .where(messageboard_id: policy_scope(Messageboard.all).pluck(:id))
        .order_newest_first
        .includes(:postable)
        .send(Kaminari.config.page_method_name, current_page)
      @posts = Thredded::PostsPageView.new(thredded_current_user, posts_scope, author: @user)
      render json: PostViewSerializer.new(@posts.post_views, include: [:post, :'post.user']).serializable_hash.to_json, status: 200
    end

    def moderate_user
      moderation_state = params[:moderation_state].to_s
      return head(:bad_request) unless Thredded::UserDetail.moderation_states.include?(moderation_state)
      user = find_user(params[:id])
      if user.thredded_user_detail.moderation_state != moderation_state
        user.thredded_user_detail.update!(moderation_state: params[:moderation_state])
        posts_scope = user.thredded_posts
          .where(messageboard_id: policy_scope(Messageboard.all).pluck(:id))
          .where(moderation_state: :pending_moderation)
        Thredded::ModerateAllPosts.run!(
          posts_scope: posts_scope,
          moderation_state: moderation_state,
          moderator: thredded_current_user,
          )
        render json: UserSerializer.new(user, include: [:thredded_user_detail]).serializable_hash.to_json, status: 200
      else
        render json: {errors: "User was already #{moderation_state}" }, status: 422
      end
    end

    private

    def moderatable_posts
      if moderatable_messageboards == Thredded::Messageboard.all
        Thredded::Post.all
      else
        Thredded::Post.where(messageboard_id: moderatable_messageboards)
      end
    end

    def accessible_post_moderation_records
      if moderatable_messageboards == Thredded::Messageboard.all
        Thredded::PostModerationRecord.all
      else
        Thredded::PostModerationRecord.where(messageboard_id: moderatable_messageboards)
      end
    end

    def moderatable_messageboards
      @moderatable_messageboards ||= thredded_current_user.thredded_can_moderate_messageboards
    end

    def current_page
      (params[:page] || 1).to_i
    end

    def preload_posts_for_moderation(posts)
      posts.includes(:user, :messageboard, :postable)
    end
  end
end
