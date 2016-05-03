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

    def self.in(messageboard)
      find_or_initialize_by(messageboard_id: messageboard.id)
    end
  end
end
