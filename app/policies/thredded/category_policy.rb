# frozen_string_literal: true

module Thredded
  class CategoryPolicy
    # The scope of readable categories.
    # CategoryPolicy must be applied separately.
    class Scope
      # @param user [Thredded.user_class]
      # @param scope [ActiveRecord::Relation<Thredded::Category>]
      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      # @return [ActiveRecord::Relation<Thredded::Category>]
      def resolve
        @scope.moderation_state_visible_to_user(@user)
      end
    end

    # @param user [Thredded.user_class]
    # @param topic [Thredded::Topic]
    def initialize(user, category)
      @user = user
      @category = category
    end

    def create?
      @user.thredded_admin?
    end

    def update?
      @user.thredded_admin?
    end

    def destroy?
      @user.thredded_admin?
    end
  end
end
