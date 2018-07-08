# frozen_string_literal: true

module Thredded
  class PostForm
    attr_reader :post, :topic
    delegate :id,
             :persisted?,
             :content,
             :content=,
             to: :@post

    # @param user [Thredded.user_class]
    # @param topic [Topic]
    # @param post [Post]
    # @param post_params [Hash]
    def initialize(user:, topic:, post: nil, post_params: {})
      @messageboard = topic.messageboard
      @topic = topic
      @post = post || topic.posts.build
      user ||= Thredded::NullUser.new

      if post_params.include?(:quote_post)
        post_params[:content] =
          Thredded::ContentFormatter.quote_content(post_params.delete(:quote_post).content)
      end
      @post.attributes = post_params.merge(
        user: (user unless user.thredded_anonymous?),
        messageboard: topic.messageboard
      )
    end

    def self.for_persisted(post)
      new(user: post.user, topic: post.postable, post: post)
    end

    def submit_path
      Thredded::UrlsHelper.url_for([@messageboard, @topic, @post, only_path: true])
    end

    def preview_path
      if @post.persisted?
        Thredded::UrlsHelper.messageboard_topic_post_preview_path(@messageboard, @topic, @post)
      else
        Thredded::UrlsHelper.preview_new_messageboard_topic_post_path(@messageboard, @topic)
      end
    end

    def save
      return false unless @post.valid?
      was_persisted = @post.persisted?
      @post.save!
      Thredded::UserTopicReadState.touch!(@post.user.id, @post) unless was_persisted
      true
    end
  end
end
