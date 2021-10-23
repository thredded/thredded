# frozen_string_literal: true

module Thredded
  class NotificationsForFollowedTopics < ActiveRecord::Base
    belongs_to :user,
               class_name: Thredded.user_class_name,
               inverse_of: :thredded_notifications_for_followed_topics
    belongs_to :messageboard,
               # If messageboard is `nil`, these are the global preferences.
               optional: true
    belongs_to :user_preference,
               primary_key: :user_id,
               foreign_key: :user_id,
               inverse_of: :notifications_for_followed_topics

    validates :user_id, presence: true

    include Thredded::NotifierPreference

    def self.default(_notifier)
      # could be moved to  `notifier.defaults(:notifications_for_followed_topics)`
      Thredded::BaseNotifier::NotificationsDefault.new(true)
    end
  end
end
