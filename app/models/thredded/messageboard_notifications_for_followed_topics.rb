# frozen_string_literal: true

module Thredded
  class MessageboardNotificationsForFollowedTopics < ActiveRecord::Base
    belongs_to :user_preference,
               primary_key: :user_id,
               foreign_key: :user_id,
               inverse_of: :messageboard_notifications_for_followed_topics
    belongs_to :user,
               class_name: Thredded.user_class_name,
               inverse_of: :thredded_messageboard_notifications_for_followed_topics
    belongs_to :messageboard
    scope :for_messageboard, ->(messageboard) { where(messageboard_id: messageboard.id) }

    validates :user_id, presence: true
    validates :messageboard_id, presence: true

    def self.in(messageboard)
      where(messageboard_id: messageboard.id)
    end

    include Thredded::NotifierPreference

    def self.default(_notifier)
      # could be moved to `notifier.defaults(:notifications_for_followed_topics)` or
      # `notifier.defaults(:messageboard_notifications_for_followed_topics)`
      Thredded::BaseNotifier::NotificationsDefault.new(true)
    end
  end
end
