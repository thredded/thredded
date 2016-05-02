# frozen_string_literal: true
require_dependency 'thredded/urls_helper'
module Thredded
  # A view model for PostCommon.
  class PostView
    delegate :filtered_content,
             :avatar_url,
             :created_at,
             :user,
             :to_model,
             to: :@post

    # @param post [Thredded::PostCommon]
    # @param policy [#update? #destroy?]
    def initialize(post, policy)
      @post   = post
      @policy = policy
    end

    def can_update?
      @can_update ||= @policy.update?
    end

    def can_destroy?
      @can_destroy ||= @policy.destroy?
    end

    def edit_path
      Thredded::UrlsHelper.edit_post_path(@post)
    end

    def destroy_path
      Thredded::UrlsHelper.delete_post_path(@post)
    end

    def cache_key
      [
        I18n.locale,
        @post,
        @post.user,
        [can_update?, can_destroy?].map { |p| p ? '+' : '-' } * ''
      ]
    end
  end
end
