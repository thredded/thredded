# frozen_string_literal: true

module Thredded
  class MarkAllRead
    def self.run(user)
      unread_topics = Thredded::PrivateTopic.unread(user)
      return if unread_topics.empty?

      unread_topics.each do |topic|
        last_post = topic.posts.order_oldest_first.last

        Thredded::UserPrivateTopicReadState.touch!(user.id, topic.id, last_post)
      end
    end
  end
end
