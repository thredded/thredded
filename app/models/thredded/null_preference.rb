# frozen_string_literal: true
module Thredded
  class NullPreference
    def follow_topics_on_mention
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
