# frozen_string_literal: true

module Thredded
  class Notification < ActiveRecord::Base
    belongs_to :user,
               class_name: Thredded.user_class_name,
               inverse_of: :thredded_notifications

    validates :name, presence: true

    # Finds the notification by its ID, or raises Thredded::Errors::NotificationNotFound.
    # @return [Thredded::Notification]
    # @raise [Thredded::Errors::NotificationNotFound] if the notification with the given id does not exist.
    def self.find!(id)
      find(id)
    rescue ActiveRecord::RecordNotFound
      raise Thredded::Errors::NotificationNotFound
    end
  end
end
