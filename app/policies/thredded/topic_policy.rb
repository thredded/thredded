# frozen_string_literal: true
require_dependency 'thredded/messageboard_policy'
module Thredded
  class TopicPolicy
    # The scope of readable topics.
    # MessageboardPolicy must be applied separately.
    class Scope
      # @param user [Thredded.user_class]
      # @param scope [ActiveRecord::Relation<Thredded::Topic>]
      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      # @return [ActiveRecord::Relation<Thredded::Topic>]
      def resolve
        @scope.moderation_state_visible_to_user(@user)
      end
    end

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
      @messageboard_user_permission.read? && @topic.moderation_state_visible_to_user?(@user)
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
