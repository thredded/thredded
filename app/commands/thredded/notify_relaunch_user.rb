# frozen_string_literal: true

module Thredded
  class NotifyRelaunchUser
    def initialize(relaunch_user)
      @relaunch_user = relaunch_user
    end

    def run
      Thredded.notifiers.each do |notifier|
        notifier.new_relaunch_user(@relaunch_user)
      end
    end
  end
end
