# frozen_string_literal: true

module Thredded
  class NotifyBadgeUserJob < ::ActiveJob::Base
    queue_as :default

    def perform(badge_id, user_id)
      badge = Thredded::Badge.find(badge_id)
      user = User.find(user_id)
      Thredded::NotifyBadgeUser.new(badge, user).run
    end
  end
end
