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
          .page(params[:page] || 1)
      )
      if flash[:last_moderated_record_id]
        @last_moderated_record = accessible_moderation_records.find(flash[:last_moderated_record_id].to_i)
      end
    end

    def history
      @post_moderation_records = accessible_moderation_records
        .order(created_at: :desc)
        .page(params[:page] || 1)
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

    private

    def moderatable_posts
      Thredded::Post.where(messageboard_id: @moderatable_messageboards)
    end

    def accessible_moderation_records
      Thredded::PostModerationRecord
        .where(messageboard_id: @moderatable_messageboards)
    end

    def load_moderatable_messageboards
      @moderatable_messageboards = thredded_current_user.thredded_can_moderate_messageboards.to_a
      if @moderatable_messageboards.empty?
        fail Pundit::NotAuthorizedError, 'You are not authorized to perform this action.'
      end
    end
  end
end
