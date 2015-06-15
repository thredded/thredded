module Thredded
  class NotificationPreference < ActiveRecord::Base
    belongs_to :user
    belongs_to :messageboard

    validates :user_id, presence: true
    validates :messageboard_id, presence: true

    def self.for(user)
      where(user_id: user.id)
    end

    def self.in(messageboard)
      where(messageboard_id: messageboard.id)
    end
  end
end
