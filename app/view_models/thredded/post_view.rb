# frozen_string_literal: true
module Thredded
  # A view model for PostCommon.
  class PostView
    delegate :filtered_content,
             :avatar_url,
             :created_at,
             :user,
             :to_model,
             :pending_moderation?,
             :approved?,
             :blocked?,
             :last_moderation_record,
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

    def can_moderate?
      @can_moderate ||= @policy.moderate?
    end

    def edit_path
      Thredded::UrlsHelper.edit_post_path(@post)
    end

    def destroy_path
      Thredded::UrlsHelper.delete_post_path(@post)
    end

    def permalink_path
      Thredded::UrlsHelper.post_permalink_path(@post.id)
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def cache_key
      moderation_state = unless @post.private_topic_post?
                           if @post.pending_moderation? && !Thredded.content_visible_while_pending_moderation
                             'p'
                           elsif @post.blocked?
                             '-'
                           end
                         end
      [
        I18n.locale,
        @post.cache_key,
        (@post.messageboard_id unless @post.private_topic_post?),
        @post.user ? @post.user.cache_key : 'users/nil',
        moderation_state || '+',
        [
          can_update?,
          can_destroy?
        ].map { |p| p ? '+' : '-' } * ''
      ].compact.join('/')
    end
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
