# frozen_string_literal: true
module Thredded
  class NullPreference
    def follow_topics_on_mention
      true
    end

    def notifications_for_private_topics
      Thredded::PerNotifierPref::NotificationsForPrivateTopics.new
    end

    def notifications_for_followed_topics
      Thredded::PerNotifierPref::NotificationsForFollowedTopics.new
    end
  end
end
