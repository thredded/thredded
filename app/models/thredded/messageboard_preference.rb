module Thredded
  class MessageboardPreference < ActiveRecord::Base
    attr_accessible :notify_on_mention, :notify_on_message, :filter
    belongs_to :user
    belongs_to :messageboard

    def self.for(user)
      where(user_id: user.id)
    end

    def self.in(messageboard)
      where(messageboard_id: messageboard.id)
    end
  end
end
