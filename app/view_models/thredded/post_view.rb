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
    # @param policy [Thredded::TopicView]
    def initialize(post, policy, topic_view: nil)
      @post   = post
      @policy = policy
      @topic_view = topic_view
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

    def mark_unread_path
      Thredded::UrlsHelper.mark_unread_path(@post)
    end

    def destroy_path
      Thredded::UrlsHelper.delete_post_path(@post)
    end

    def permalink_path
      Thredded::UrlsHelper.post_permalink_path(@post.id)
    end

    def read_state_class
      case read_state
      when POST_IS_UNREAD
        'thredded--unread--post'
      when POST_IS_READ
        'thredded--read--post'
      end
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
        read_state,
        moderation_state || '+',
        [
          can_update?,
          can_destroy?
        ].map { |p| p ? '+' : '-' } * ''

      ].compact.join('/')
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    POST_IS_READ = :r
    POST_IS_UNREAD = :u

    # returns nil if read state is not appropriate to the view (i.e. viewing posts outside a topic)
    def read_state
      if @topic_view.nil? || @policy.anonymous?
        nil
      elsif @topic_view.post_read?(@post)
        POST_IS_READ
      else
        POST_IS_UNREAD
      end
    end
  end
end
