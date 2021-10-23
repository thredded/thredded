# frozen_string_literal: true

module Thredded
  module UrlsHelper # rubocop:disable Metrics/ModuleLength
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
      post_url(post, **params.merge(user: user, only_path: true))
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

    # @param [Thredded::Messageboard, nil] messageboard
    # @param [Hash] params additional params
    def unread_topics_path(messageboard: nil, **params)
      params[:only_path] = true
      if messageboard
        unread_messageboard_topics_url(messageboard, params)
      else
        unread_topics_url(params)
      end
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

    def quote_post_path(post)
      if post.private_topic_post?
        quote_private_topic_private_post_path(post.postable, post)
      else
        quote_messageboard_topic_post_path(post.messageboard, post.postable, post)
      end
    end

    def mark_unread_path(post, _params = {})
      if post.private_topic_post?
        mark_as_unread_private_post_path(post)
      else
        mark_as_unread_post_path(post)
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

    # @param [Thredded.user_class] current_user
    # @param [Thredded.user_class] to
    # @param [Boolean] use_existing Whether to use the existing thread if any.
    # @return [String] a path to a new or existing private message thread for the given users.
    def send_private_message_path(current_user:, to:, use_existing: true)
      existing_topic = use_existing &&
                       Thredded::PrivateTopic.has_exact_participants([current_user, to])
                         .order_recently_posted_first.first
      if existing_topic
        page = 1 + (existing_topic.posts_count - 1) / Thredded::PrivatePost.default_per_page
        Thredded::UrlsHelper.private_topic_path(
          existing_topic,
          page: (page if page > 1),
          autofocus_new_post_content: true,
          anchor: 'post_content'
        )
      else
        Thredded::UrlsHelper.new_private_topic_path(
          private_topic: {
            user_names: to.send(Thredded.user_name_column),
            title: [current_user, to].map(&Thredded.user_display_name_method).join(' • ')
          },
          autofocus_new_post_content: true,
        )
      end
    end
  end
end
