# frozen_string_literal: true

module Thredded
  class BadgePolicy
    # The scope of readable categories.
    # CategoryPolicy must be applied separately.
    class Scope
      # @param user [Thredded.user_class]
      # @param scope [ActiveRecord::Relation<Thredded::Badge>]
      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      # @return [ActiveRecord::Relation<Thredded::Badge>]
      def resolve
        if @user.thredded_admin?
          @scope.all
        elsif !@user.thredded_anonymous?
          user_badges = @user.thredded_badges
          @scope.where(secret: false).or(@scope.where(id: (user_badges.map(&:id))))
        else
          @scope.where(secret: false)
        end
      end
    end

    # @param user [Thredded.user_class]
    # @param badge [Thredded::Badge]
    def initialize(user, badge)
      @user = user
      @badge = badge
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
