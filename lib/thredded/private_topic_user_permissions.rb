# frozen_string_literal: true
module Thredded
  class PrivateTopicUserPermissions
    def initialize(private_topic, user)
      @private_topic = private_topic
      @user = user
    end

    def creatable?
      !@user.thredded_anonymous?
    end

    def editable?
      user_started_topic?
    end

    def readable?
      @private_topic.users.include?(@user)
    end

    private

    def user_started_topic?
      @user.id == @private_topic.user_id
    end
  end
end
