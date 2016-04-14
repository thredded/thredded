# frozen_string_literal: true
module Thredded
  class TopicUserPermissions
    def initialize(topic, user)
      @topic = topic
      @user = user
      @messageboard_user_permission = MessageboardUserPermissions.new(topic.messageboard, user)
    end

    def moderatable?
      @messageboard_user_permission.moderatable?
    end

    def creatable?
      @messageboard_user_permission.postable?
    end

    def editable?
      started_by_user? || moderatable?
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
