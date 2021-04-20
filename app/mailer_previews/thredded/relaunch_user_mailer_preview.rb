# frozen_string_literal: true

module Thredded
  # Previews for the PrivateTopicMailer
  class RelaunchUserMailerPreview < BaseMailerPreview
    def new_relaunch_user
      RelaunchUserMailer.new_relaunch_user(
        '10',
        'christl@brickboard.com',
        'christl_bricki',
        'asdasd343sds2sd4'
      )
    end
  end
end
