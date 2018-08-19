# frozen_string_literal: true

module Thredded
  class MessageboardPolicy
    # The scope of readable messageboards
    class Scope
      # @param user [Thredded.user_class]
      # @param scope [ActiveRecord::Relation<Thredded::Messageboard>]
      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      # @return [ActiveRecord::Relation<Thredded::Messageboards>]
      def resolve
        readable = @user.thredded_can_read_messageboards
        if readable == Thredded::Messageboard.all
          @scope
        else
          @scope.merge(readable)
        end
      end
    end

    # @param user [Thredded.user_class]
    # @param messageboard [Thredded::Messageboard]
    def initialize(user, messageboard)
      @user = user
      @messageboard = messageboard
    end

    def create?
      @user.thredded_admin?
    end

    def read?
      @user.thredded_admin? || @user.thredded_can_read_messageboard?(@messageboard)
    end

    def update?
      @user.thredded_admin?
    end

    def post?
      @user.thredded_admin? ||
        (!@messageboard.locked? || moderate?) &&
          @user.thredded_can_write_messageboards.include?(@messageboard)
    end

    def moderate?
      @user.thredded_admin? || @user.thredded_can_moderate_messageboard?(@messageboard)
    end
  end
end
