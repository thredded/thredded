require 'support/features/page_object/base'

module PageObject
  class NotificationPreferences < Base
    attr_accessor :user, :messageboard

    def initialize(user, messageboard = create(:messageboard))
      @user = user
      @messageboard = messageboard
    end

    def visit_style_guide
      signs_in_as(user.to_s)
      visit theme_path
    end

    def disable_at_notifications
      uncheck "Notify me when I am @'ed"
      click_button 'Update Preferences'
    end

    def updated?
      has_content? 'Your preferences are updated'
    end

    def has_at_mention_notifications?
      has_checked_field? 'notification_preference_notify_on_mention'
    end

    def disable_private_topic_notifications
      uncheck 'Notify me when I am included in a private topic'
      click_button 'Update Preferences'
    end

    def has_private_topic_notifications?
      has_checked_field? 'notification_preference_notify_on_message'
    end
  end
end
