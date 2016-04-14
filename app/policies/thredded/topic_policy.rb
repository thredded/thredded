# frozen_string_literal: true
module Thredded
  class TopicPolicy
    # @param user [Thredded.user_class]
    # @param topic [Thredded::Topic]
    def initialize(user, topic)
      @user = user
      @topic = topic
      @messageboard_user_permission = MessageboardPolicy.new(user, topic.messageboard)
    end

    def create?
      @messageboard_user_permission.post?
    end

    def read?
      @messageboard_user_permission.read?
    end

    def update?
      @user.thredded_admin? || @topic.user_id == @user.id || moderate?
    end

    def destroy?
      @user.thredded_admin?
    end

    def moderate?
      @messageboard_user_permission.moderate?
    end
  end
end
