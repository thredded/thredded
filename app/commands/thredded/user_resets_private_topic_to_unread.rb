module Thredded
  class UserResetsPrivateTopicToUnread
    def initialize(private_topic, user)
      @private_topic = private_topic
      @user = user
    end

    def run
      other_users = Thredded::PrivateUser
        .where(private_topic: private_topic)
        .where('user_id != ?', user.id)
      other_users.update_all(read: false)

      other_users.each do |other_user|
        Rails.cache.delete("private_topics_count_#{messageboard.id}_#{other_user.user_id}")
      end
      Rails.cache.delete("private_topics_count_#{messageboard.id}_#{user.id}")
    end

    private

    attr_reader :private_topic, :user

    def messageboard
      private_topic.messageboard
    end
  end
end
