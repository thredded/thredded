require 'support/features/page_object/base'

module PageObject
  class MessageboardPreferences < Base
    attr_accessor :user, :messageboard

    def initialize(user, messageboard = create(:messageboard))
      @user = user
      @messageboard = messageboard
    end

    def visit_preferences
      signs_in_as(user.to_s)
      visit edit_messageboard_preferences_path(messageboard)
    end

    def disable_at_notifications
      uncheck "Notify me when I am @'ed"
      click_button 'Update Preferences'
    end

    def update_to_bbcode
      select 'bbcode', from: 'Preferred post filter'
      click_button 'Update Preferences'
    end

    def update_to_markdown
      select 'markdown', from: 'Preferred post filter'
      click_button 'Update Preferences'
    end

    def updated?
      has_content? 'Your preferences are updated'
    end

    def has_bbcode_as_the_post_filter?
      filter = find_field('messageboard_preference_filter')
        .find('option[selected]')
        .text

      filter == 'bbcode'
    end

    def has_markdown_as_the_post_filter?
      filter = find_field('messageboard_preference_filter')
        .find('option[selected]')
        .text

      filter == 'markdown'
    end

    def has_at_mention_notifications?
      has_checked_field? 'messageboard_preference_notify_on_mention'
    end

    def disable_private_topic_notifications
      uncheck 'Notify me when I am included in a private topic'
      click_button 'Update Preferences'
    end

    def has_private_topic_notifications?
      has_checked_field? 'messageboard_preference_notify_on_message'
    end
  end
end
