# frozen_string_literal: true

module Thredded
  # A view model for Messageboard.
  class MessageboardView
    delegate :name,
             :description,
             :locked?,
             :last_topic,
             :last_user,
             to: :@messageboard

    # @return [Integer]
    attr_reader :topics_count

    # @return [Integer]
    attr_reader :posts_count

    # @return [Integer]
    attr_reader :unread_topics_count

    # @return [Integer]
    attr_reader :unread_followed_topics_count

    # @return [Integer]
    attr_reader :id

    # @return [Thredded::Messageboard]
    attr_reader :messageboard

    # @param [Thredded::Messageboard] messageboard
    # @param [Integer] topics_count
    # @param [Integer] posts_count
    # @param [Integer] unread_topics_count
    # @param [Integer] unread_followed_topics_count
    def initialize(
      messageboard,
      topics_count: messageboard.topics_count,
      posts_count: messageboard.posts_count,
      unread_topics_count: 0,
      unread_followed_topics_count: 0
    )
      @messageboard = messageboard
      @topics_count = topics_count
      @posts_count = posts_count
      @unread_topics_count = unread_topics_count
      @unread_followed_topics_count = unread_followed_topics_count
      @id = nil
    end

    # @return [Boolean]
    def unread_topics?
      !@unread_topics_count.zero?
    end

    # @return [Boolean]
    def unread_followed_topics?
      !@unread_followed_topics_count.zero?
    end

    # @return [String]
    def path
      Thredded::UrlsHelper.messageboard_topics_path(@messageboard)
    end

    # @return [String]
    def edit_preferences_path
      Thredded::UrlsHelper.edit_messageboard_preferences_path(@messageboard)
    end
  end
end
