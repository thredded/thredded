# frozen_string_literal: true
module Thredded
  class UserMessageboardPreference < ActiveRecord::Base
    belongs_to :user_preference,
               primary_key: :user_id,
               foreign_key: :user_id,
               inverse_of: :messageboard_preferences
    belongs_to :user,
               class_name: Thredded.user_class,
               inverse_of: :thredded_user_messageboard_preferences
    belongs_to :messageboard

    validates :user_id, presence: true
    validates :messageboard_id, presence: true

    serialize :notifications_for_followed_topics, PerNotifierPref::MessageboardNotificationsForFollowedTopics

    def self.in(messageboard)
      find_or_initialize_by(messageboard_id: messageboard.id)
    end

    def notifications_for_followed_topics=(h)
      super(h) if h.is_a?(Thredded::PerNotifierPref::MessageboardNotificationsForFollowedTopics)
      self[:notifications_for_followed_topics] =
        Thredded::PerNotifierPref::MessageboardNotificationsForFollowedTopics.new(h)
    end
  end
end
