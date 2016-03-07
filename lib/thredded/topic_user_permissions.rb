module Thredded
  class TopicUserPermissions
    def initialize(topic, user, _user_details)
      @topic = topic
      @messageboard = topic.messageboard
      @messageboard_user_permission = MessageboardUserPermissions.new(topic.messageboard, user)
      @user = user
    end

    def creatable?
      @messageboard_user_permission.postable?
    end

    def adminable?
      @messageboard_user_permission.moderatable?
    end

    def editable?
      started_by_user? || adminable?
    end

    def readable?
      @messageboard_user_permission.readable?
    end

    private

    def started_by_user?
      @topic.user_id == @user.id
    end
  end
end
