# frozen_string_literal: true

module Thredded
  # A view model for Messageboard.
  class MessageboardView
    delegate :name,
             :description,
             :locked?,
             :topics_count,
             :posts_count,
             :last_topic,
             :last_user,
             to: :@messageboard

    # @return [Integer]
    attr_reader :unread_topics_count

    # @return [Integer]
    attr_reader :unread_followed_topics_count

    # @param [Thredded::Messageboard] messageboard
    # @param [Integer] unread_topics_count
    # @param [Integer] unread_followed_topics_count
    def initialize(messageboard, unread_topics_count: 0, unread_followed_topics_count: 0)
      @messageboard = messageboard
      @unread_topics_count = unread_topics_count
      @unread_followed_topics_count = unread_followed_topics_count
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
