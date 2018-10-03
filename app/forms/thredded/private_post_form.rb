# frozen_string_literal: true

module Thredded
  class PrivatePostForm
    attr_reader :post, :topic
    delegate :id,
             :persisted?,
             :content,
             :content=,
             to: :@post

    # @param user [Thredded.user_class]
    # @param topic [PrivateTopic]
    # @param post [PrivatePost]
    # @param post_params [Hash]
    def initialize(user:, topic:, post: nil, post_params: {})
      @topic = topic
      @post = post || topic.posts.build
      user ||= Thredded::NullUser.new

      if post_params.include?(:quote_post)
        post_params[:content] =
          Thredded::ContentFormatter.quote_content(post_params.delete(:quote_post).content)
      end
      @post.attributes = post_params.merge(user: (user unless user.thredded_anonymous?))
    end

    def self.for_persisted(post)
      new(user: post.user, topic: post.postable, post: post)
    end

    def submit_path
      Thredded::UrlsHelper.url_for([@topic, @post, only_path: true])
    end

    def preview_path
      if @post.persisted?
        Thredded::UrlsHelper.private_topic_private_post_preview_path(@topic, @post)
      else
        Thredded::UrlsHelper.preview_new_private_topic_private_post_path(@topic)
      end
    end

    def save
      return false unless @post.valid?
      was_persisted = @post.persisted?
      @post.save!
      Thredded::UserPrivateTopicReadState.touch!(@post.user.id, @post) unless was_persisted
      true
    end
  end
end
