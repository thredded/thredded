# frozen_string_literal: true
require_dependency 'thredded/moderate_post'
require_dependency 'thredded/posts_page_view'
module Thredded
  class ModerationController < ApplicationController
    before_action :thredded_require_login!
    before_action :load_moderatable_messageboards

    def pending
      @posts = PostsPageView.new(
        thredded_current_user,
        moderatable_posts
          .pending_moderation
          .order_oldest_first
          .preload(:user, :postable)
          .page(current_page)
      )
      if flash[:last_moderated_record_id]
        @last_moderated_record = accessible_post_moderation_records.find(flash[:last_moderated_record_id].to_i)
      end
    end

    def history
      @post_moderation_records = accessible_post_moderation_records
        .order(created_at: :desc)
        .page(current_page)
    end

    def activity
      @posts = PostsPageView.new(
        thredded_current_user,
        moderatable_posts
          .order_newest_first
          .preload(:user, :postable)
          .page(current_page)
      )
      if flash[:last_moderated_record_id]
        @last_moderated_record = accessible_post_moderation_records.find(flash[:last_moderated_record_id].to_i)
      end
    end

    def moderate_post
      return head(:bad_request) unless Thredded::Post.moderation_states.include?(params[:moderation_state])
      flash[:last_moderated_record_id] = ModeratePost.run!(
        post: moderatable_posts.find(params[:id]),
        moderation_state: params[:moderation_state],
        moderator: thredded_current_user,
      ).id
      redirect_back fallback_location: pending_moderation_path
    end

    def users
      @users = Thredded.user_class
        .left_join_thredded_user_details
        .merge(Thredded::UserDetail.order(moderation_state_changed_at: :desc))
      @query = params[:q].to_s
      if @query.present?
        @users = DbTextSearch::CaseInsensitive.new(@users, Thredded.user_name_column).prefix(@query)
      end
      @users = @users.page(current_page)
    end

    def user
      @user = Thredded.user_class.find(params[:id])
      # Do not apply policy_scope here, as we want to show blocked posts as well.
      posts_scope = @user.thredded_posts
        .where(messageboard_id: policy_scope(Messageboard.all).pluck(:id))
        .order_newest_first
        .includes(:postable)
        .page(current_page)
      @posts = PostsPageView.new(thredded_current_user, posts_scope)
    end

    def moderate_user
      return head(:bad_request) unless Thredded::UserDetail.moderation_states.include?(params[:moderation_state])
      user = Thredded.user_class.find(params[:id])
      user.thredded_user_detail.update!(moderation_state: params[:moderation_state])
      redirect_back fallback_location: user_moderation_path(user.id)
    end

    private

    def moderatable_posts
      Thredded::Post.where(messageboard_id: @moderatable_messageboards)
    end

    def accessible_post_moderation_records
      Thredded::PostModerationRecord
        .where(messageboard_id: @moderatable_messageboards)
    end

    def load_moderatable_messageboards
      @moderatable_messageboards = thredded_current_user.thredded_can_moderate_messageboards.to_a
      if @moderatable_messageboards.empty?
        fail Pundit::NotAuthorizedError, 'You are not authorized to perform this action.'
      end
    end

    def current_page
      (params[:page] || 1).to_i
    end
  end
end
