# frozen_string_literal: true

module Thredded
  # Marks all private topics as read for the given user.
  class MarkAllReadTopic
    def self.run(user, topic)
      Thredded::UserTopicReadState.touch!(user.id, topic.last_post)
    end
  end
end
