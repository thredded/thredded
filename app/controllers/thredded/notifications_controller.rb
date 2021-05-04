# frozen_string_literal: true
module Thredded
  class NotificationsController < Thredded::ApplicationController # rubocop:disable Metrics/ClassLength
    before_action :thredded_require_login!
    after_action :verify_authorized, except: [:destroy_all]

    def destroy
      authorize notification, :destroy?
      notification.destroy!
      head 204
    end

    def destroy_all
      notifications = thredded_current_user.thredded_notifications
      notifications.each do |notification|
        authorize notification, :destroy?
        notification.destroy!
      end
      head 204
    end

    private

    # Returns the `@notification` instance variable.
    # If `@notification` is not set, it first sets it to the topic with the slug or ID given by `params[:id]`.
    #
    # @return [Thredded::Notification]
    # @raise [Thredded::Errors::NotificationNotFound] if the notification with the given slug does not exist.
    def notification
      @notification ||= Thredded::Notification.find!(params[:id])
    end
  end
end
