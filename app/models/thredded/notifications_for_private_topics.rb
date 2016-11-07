# frozen_string_literal: true
module Thredded
  class NotificationsForPrivateTopics < ActiveRecord::Base
    belongs_to :user,
               class_name: Thredded.user_class,
               inverse_of: :thredded_notifications_for_private_topics
    belongs_to :user_preference,
               primary_key: :user_id,
               foreign_key: :user_id,
               inverse_of: :notifications_for_private_topics

    validates :user_id, presence: true
  end
end
