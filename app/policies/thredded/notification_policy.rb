# frozen_string_literal: true

module Thredded
  class NotificationPolicy
    # @param user [Thredded.user_class]
    # @param notification [Thredded::Notification]
    def initialize(user, notification)
      @user                = user
      @notification        = notification
    end

    def read?
      @user.thredded_admin? || @notification.user_id == @user.id
    end

    def destroy?
      @user.thredded_admin? || @notification.user_id == @user.id
    end
  end
end
