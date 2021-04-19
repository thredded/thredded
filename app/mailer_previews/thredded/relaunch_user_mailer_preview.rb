# frozen_string_literal: true

module Thredded
  # Previews for the PrivateTopicMailer
  class RelaunchUserMailerPreview < BaseMailerPreview
    def new_relaunch_user
      RelaunchUserMailer.new_relaunch_user(
        'christl@brickboard.com',
        'christl_bricki'
      )
    end
  end
end
