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
    # @param policy [#create? #update? #destroy? #moderate?]
    # @param topic_view [Thredded::TopicView]
    def initialize(post, policy, topic_view: nil)
      @post   = post
      @policy = policy
      @topic_view = topic_view
    end

    def can_reply?
      @can_reply ||= @policy.create?
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

    def quote_url_params
      if @post.private_topic_post?
        { post: { quote_private_post_id: @post.id } }
      else
        { post: { quote_post_id: @post.id } }
      end.update(anchor: 'post_content')
    end

    def quote_path
      Thredded::UrlsHelper.quote_post_path(@post)
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
      Thredded::UrlsHelper.permalink_path(@post)
    end

    # This cache key is used only for caching the content.
    def cache_key
      @post.cache_key
    end

    POST_IS_READ = :read
    POST_IS_UNREAD = :unread

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
