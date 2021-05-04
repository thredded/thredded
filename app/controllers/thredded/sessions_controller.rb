# frozen_string_literal: true

module Thredded
  class SessionsController < Thredded::ApplicationController
    def logged_in_user
      fail Thredded::Errors::SessionNotLoggedIn if thredded_current_user.thredded_anonymous?
      fail Thredded::Errors::SessionBlocked if thredded_current_user.thredded_user_detail.blocked?
      render json: NotificationSerializer.new(thredded_current_user.thredded_notifications).serializable_hash.to_json, status: 200
    end
  end
end
