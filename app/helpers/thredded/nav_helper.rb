# frozen_string_literal: true

require 'set'
module Thredded
  module NavHelper
    USER_NAV_MODERATION_PAGES = Set.new(
      %w[
        thredded--pending-moderation
        thredded--moderation-activity
        thredded--moderation-history
        thredded--moderation-users
        thredded--moderation-user
      ]
    )

    USER_NAV_PREFERENCES_PAGES = Set.new(
      %w[
        thredded--preferences
      ]
    )

    USER_NAV_PRIVATE_TOPICS_PAGES = Set.new(
      %w[
        thredded--new-private-topic
        thredded--private-topics-index
        thredded--private-topic-show
      ]
    )

    USER_NAV_UNREAD_TOPICS = Set.new(
      %w[thredded--unread-topics]
    )

    def current_page_unread_topics?
      USER_NAV_UNREAD_TOPICS.include?(content_for(:thredded_page_id))
    end

    def current_page_preferences?
      USER_NAV_PREFERENCES_PAGES.include?(content_for(:thredded_page_id))
    end

    def current_page_moderation?
      USER_NAV_MODERATION_PAGES.include?(content_for(:thredded_page_id))
    end

    def current_page_private_topics?
      USER_NAV_PRIVATE_TOPICS_PAGES.include?(content_for(:thredded_page_id))
    end

    def nav_back_path(messageboard = nil)
      messageboard ? messageboard_topics_path(messageboard) : messageboards_path
    end
  end
end
