# frozen_string_literal: true
module Thredded
  class UserPreference < ActiveRecord::Base
    belongs_to :user, class_name: Thredded.user_class, inverse_of: :thredded_user_preference
    has_many :messageboard_preferences,
             class_name: 'Thredded::UserMessageboardPreference',
             primary_key: :user_id,
             foreign_key: :user_id,
             inverse_of: :user_preference
    has_many :messageboard_notifications_for_followed_topics,
             class_name: 'Thredded::MessageboardNotificationsForFollowedTopics',
             primary_key: :user_id,
             foreign_key: :user_id,
             inverse_of: :user_preference
    has_many :notifications_for_followed_topics,
             class_name: 'Thredded::NotificationsForFollowedTopics',
             primary_key: :user_id,
             foreign_key: :user_id,
             inverse_of: :user_preference
    has_many :notifications_for_private_topics,
             class_name: 'Thredded::NotificationsForPrivateTopics',
             primary_key: :user_id,
             foreign_key: :user_id,
             inverse_of: :user_preference

    validates :user_id, presence: true

    accepts_nested_attributes_for :notifications_for_followed_topics,
                                  :notifications_for_private_topics,
                                  :messageboard_notifications_for_followed_topics
  end
end
