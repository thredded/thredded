# frozen_string_literal: true
module Thredded
  class NullPreference
    def auto_follow_topics
      true
    end

    def notify_on_message
      true
    end

    def followed_topic_emails
      true
    end
  end
end
