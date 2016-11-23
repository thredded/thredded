# frozen_string_literal: true
module Thredded
  class NotificationsForFollowedTopics < ActiveRecord::Base
    belongs_to :user,
               class_name: Thredded.user_class,
               inverse_of: :thredded_notifications_for_followed_topics
    belongs_to :messageboard # or is global
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
