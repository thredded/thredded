require 'support/features/page_object/base'

module PageObject
  class NotificationPreferences < Base
    attr_accessor :user, :messageboard

    def initialize(user, messageboard = create(:messageboard))
      @user = user
      @messageboard = messageboard
    end

    def visit_notification_edit
      signs_in_as user
      visit edit_messageboard_preferences_path(messageboard)
    end

    def disable_at_notifications
      uncheck '@ Notifications'
      click_button 'Update Settings'
    end

    def updated?
      has_content? 'Your settings have been updated.'
    end

    def has_at_mention_notifications?
      has_checked_field? 'notification_preference_notify_on_mention'
    end

    def disable_private_topic_notifications
      uncheck 'Private Topic Notification'
      click_button 'Update Settings'
    end

    def has_private_topic_notifications?
      has_checked_field? 'notification_preference_notify_on_message'
    end
  end
end
