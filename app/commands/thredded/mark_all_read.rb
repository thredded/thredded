# frozen_string_literal: true

module Thredded
  # Marks all private topics as read for the given user.
  class MarkAllRead
    def self.run(user)
      Thredded::PrivateTopic.unread(user).each do |topic|
        Thredded::UserPrivateTopicReadState.touch!(user.id, topic.last_post)
      end
    end
  end
end
