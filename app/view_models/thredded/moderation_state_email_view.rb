# frozen_string_literal: true

module Thredded
  class ModerationStateEmailView
    # @param [Thredded::TopicCommon] topic
    def initialize(user_detail)
      @user_detail = user_detail
    end

    def smtp_api_tag(tag)
      %({"category": ["thredded_notification","#{tag}"]})
    end

    def no_reply
      Thredded.email_from
    end
  end
end
