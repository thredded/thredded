# frozen_string_literal: true

module Thredded
  class UserDetailPolicy
    # The scope of readable topics.
    # MessageboardPolicy must be applied separately.
    class Scope
      # @param user [Thredded.user_class]
      # @param scope [ActiveRecord::Relation<Thredded::Topic>]
      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        @scope
      end
    end

    # @param user [Thredded.user_class]
    # @param topic [Thredded::Topic]
    def initialize(user, user_details)
      @user = user
      @user_details = user_details
    end

    def update?
      @user_details.user.id == @user.id
    end
  end
end
