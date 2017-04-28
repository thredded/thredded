# frozen_string_literal: true
module Thredded
  module UrlsHelper
    class << self
      include Thredded::Engine.routes.url_helpers
      include Thredded::UrlsHelper
    end

    # @param user [Thredded.user_class, Thredded::NullUser]
    # @return [String] path to the user as specified by {Thredded.user_path}
    def user_path(user)
      Thredded.user_path(self, user)
    end

    # @param topic [Topic, PrivateTopic, UserTopicDecorator, UserPrivateTopicDecorator]
    # @return [String]
    def topic_url(topic, params = {})
      if params[:page] == 1
        params = params.dup
        params.delete(:page)
      end
      if topic.private?
        private_topic_url(
          topic.slug,
          params
        )
      else
        messageboard_topic_url(
          topic.messageboard.slug,
          topic.slug,
          params
        )
      end
    end

    # @param topic [Topic, PrivateTopic, UserTopicDecorator, UserPrivateTopicDecorator]
    # @return [String] path to the latest unread page of the given topic.
    def topic_path(topic, params = {})
      topic_url(topic, params.merge(only_path: true))
    end

    # @param post [Post, PrivatePost]
    # @param user [Thredded.user_class] the current user
    # @return [String] URL of the topic page with the post anchor.
    def post_url(post, user:, **params)
      params = params.dup
      params[:anchor] ||= ActionView::RecordIdentifier.dom_id(post)
      params[:page] ||= post.private_topic_post? ? post.page : post.page(user: user)
      topic_url(post.postable, params)
    end

    # @param post [Post, PrivatePost]
    # @param user [Thredded.user_class] the current user
    # @return [String] path to the topic page with the post anchor.
    def post_path(post, user:, **params)
      post_url(post, params.merge(user: user, only_path: true))
    end

    # @param post [Post, PrivatePost]
    # @return [String] path to the Edit Post page.
    def edit_post_path(post)
      if post.private_topic_post?
        edit_private_topic_private_post_path(post.postable, post)
      else
        edit_messageboard_topic_post_path(post.messageboard, post.postable, post)
      end
    end

    # @param post [Post, PrivatePost]
    # @return [String] path to the DELETE endpoint.
    def delete_post_path(post)
      if post.private_topic_post?
        private_topic_private_post_path(post.postable, post)
      else
        messageboard_topic_post_path(post.messageboard, post.postable, post)
      end
    end

    # @param messageboard [Thredded::Messageboard, nil]
    # @param params [Hash] additional params
    # @return [String] the URL to the global or messageboard edit preferences page.
    def edit_preferences_url(messageboard = nil, params = {})
      if messageboard.try(:persisted?)
        edit_messageboard_preferences_url(messageboard, params)
      else
        edit_global_preferences_url(params)
      end
    end

    # @param messageboard [Thredded::Messageboard, nil]
    # @param params [Hash] additional params
    # @return [String] the path to the global or messageboard edit preferences page.
    def edit_preferences_path(messageboard = nil, params = {})
      edit_preferences_url(messageboard, params.merge(only_path: true))
    end

    # @param messageboard [Thredded::Messageboard, nil]
    # @return [String] the path to the global or messageboard search.
    def search_path(messageboard = nil)
      if messageboard.try(:persisted?)
        messageboard_search_path(messageboard)
      else
        messageboards_search_path
      end
    end

    def mark_unread_path(post, _params = {})
      if post.private_topic_post?
        mark_as_unread_private_topic_private_post_path(post.postable, post)
      else
        mark_as_unread_messageboard_topic_post_path(post.messageboard, post.postable, post)
      end
    end

    # @param post [Post, PrivatePost]
    # @return [String] post permalink path
    def permalink_path(post)
      if post.private_topic_post?
        private_post_permalink_path(post)
      else
        post_permalink_path(post)
      end
    end
  end
end
