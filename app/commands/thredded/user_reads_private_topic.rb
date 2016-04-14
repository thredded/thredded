# frozen_string_literal: true
module Thredded
  class UserReadsPrivateTopic
    def initialize(private_topic, user)
      @private_topic = private_topic
      @user = user
    end

    def run
      private_user = Thredded::PrivateUser
        .find_by(private_topic_id: private_topic.id, user_id: user.id)
      private_user.update_attributes(read: true)
    end

    private

    attr_reader :private_topic, :user

    def messageboard
      private_topic.messageboard
    end
  end
end
