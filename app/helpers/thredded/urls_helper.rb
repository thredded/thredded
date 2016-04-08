module Thredded
  module UrlsHelper
    # @param user [Thredded.user_class, Thredded::NullUser]
    # @return [String] path to the user as specified by {Thredded.user_path}
    def user_path(user)
      Thredded.user_path(self, user)
    end

    # @param topic [Topic, PrivateTopic, UserTopicDecorator, UserPrivateTopicDecorator]
    # @return [String]
    def topic_url(topic, params = {})
      # TODO: make this return the URL of last unread post by default
      # TODO: farthest_page always returns 1, fix.
      params = params.dup
      if !params[:page] && topic.respond_to?(:farthest_page)
        params[:page] = topic.farthest_page
        params[:page] = nil if params[:page] == 1
      end
      if topic.private?
        private_topic_url(
          topic.slug,
          params)
      else
        messageboard_topic_url(
          topic.messageboard.slug,
          topic.slug,
          params)
      end
    end

    # @param topic [Topic, PrivateTopic, UserTopicDecorator, UserPrivateTopicDecorator]
    # @return [String] path to the latest unread page of the given topic.
    def topic_path(topic, params = {})
      topic_url(topic, params.merge(only_path: true))
    end

    # @param post [Post, PrivatePost]
    # @return [String] URL of the topic page with the post anchor.
    def post_url(post, params = {})
      params = params.dup
      params[:anchor] ||= dom_id(post)
      params[:page] ||= post.page
      topic_url(post.postable, params)
    end

    # @param post [Post, PrivatePost]
    # @return [String] path to the topic page with the post anchor.
    def post_path(post, params = {})
      post_url(post, params.merge(only_path: true))
    end

    # @param post [Post, PrivatePost]
    # @return [String] path to the Edit Post page.
    def edit_post_path(post)
      if post.private_topic_post?
        edit_private_topic_private_post_path(post.postable, post)
      else
        edit_messageboard_topic_post_path(messageboard, post.postable, post)
      end
    end
  end
end
