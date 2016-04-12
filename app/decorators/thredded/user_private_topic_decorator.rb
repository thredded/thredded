module Thredded
  class UserPrivateTopicDecorator < BaseUserTopicDecorator
    def self.topic_class
      PrivateTopic
    end

    def read?
      topic.private_users.find_by(user: user).try(:read?)
    end
  end
end
