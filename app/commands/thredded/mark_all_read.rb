# frozen_string_literal: true
module Thredded
  class MarkAllRead
    def initialize(topic_type, user)
      @topic_type = topic_type
      @user = user
    end

    def run
      @topic_type.unread(@user).each do |topic|
        last_post = topic.posts.last
        total_pages = topic.posts.page(1).total_pages
        UserPrivateTopicReadState.touch!(
          @user.id,
          topic.id,
          last_post,
          total_pages
        )
      end
    end

    def self.run(topic_type, user)
      new(topic_type, user).run
    end
  end
end
