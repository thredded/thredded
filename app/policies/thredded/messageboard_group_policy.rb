# frozen_string_literal: true
module Thredded
  class MessageboardGroupPolicy
    # @param user [Thredded.user_class]
    # @param group [Thredded::MessageboardGroup]
    def initialize(user, group)
      @user = user
      @group = group
    end

    def create?
      @user.thredded_admin?
    end
  end
end
