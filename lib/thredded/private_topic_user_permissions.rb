module Thredded
  class PrivateTopicUserPermissions
    def initialize(private_topic, user, _user_details)
      @private_topic = private_topic
      @user = user
    end

    def readable?
      @private_topic.users.include?(@user)
    end

    def manageable?
      user_started_topic?
    end

    def creatable?
      !@user.thredded_anonymous?
    end

    private

    def user_started_topic?
      @user.id == @private_topic.user_id
    end
  end
end
