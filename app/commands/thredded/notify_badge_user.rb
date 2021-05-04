# frozen_string_literal: true

module Thredded
  class NotifyBadgeUser
    # @param badge [Thredded::Badge]
    # @param user [Thredded.user_class]
    def initialize(badge, user)
      @badge = badge
      @user = user
    end

    def run
      Thredded.notifiers.each do |notifier|
        notifier.new_badge(@badge, @user)
      end
    end
  end
end
