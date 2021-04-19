# frozen_string_literal: true

module Thredded
  class DefaultEmailView

    def smtp_api_tag(tag)
      %({"category": ["thredded_notification","#{tag}"]})
    end

    def no_reply
      Thredded.email_from
    end
  end
end
