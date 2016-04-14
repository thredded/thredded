# frozen_string_literal: true
module Thredded
  class PrivateTopicPolicy
    # @param user [Thredded.user_class]
    # @param private_topic [Thredded::PrivateTopic]
    def initialize(user, private_topic)
      @private_topic = private_topic
      @user = user
    end

    def create?
      !@user.thredded_anonymous?
    end

    def read?
      @private_topic.users.include?(@user)
    end

    def update?
      @user.id == @private_topic.user_id
    end
  end
end
