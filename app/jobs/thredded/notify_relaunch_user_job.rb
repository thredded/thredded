# frozen_string_literal: true

module Thredded
  class NotifyRelaunchUserJob < ::ActiveJob::Base
    queue_as :default

    def perform(relaunch_user_id)
      relaunch_user = Thredded::RelaunchUser.find(relaunch_user_id)
      Thredded::NotifyRelaunchUser.new(relaunch_user).run
    end
  end
end
