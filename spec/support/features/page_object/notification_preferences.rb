# frozen_string_literal: true
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
      if @messageboard
        visit edit_messageboard_preferences_path(messageboard)
      else
        visit edit_global_preferences_path(messageboard)
      end
    end

    def disable_at_notifications
      uncheck 'user_preferences_form[notify_on_mention]'
      click_button I18n.t('thredded.preferences.form.submit_btn')
    end

    def updated?
      has_content? I18n.t('thredded.preferences.updated_notice')
    end

    def has_at_mention_notifications?
      has_checked_field? 'user_preferences_form[notify_on_mention]'
    end

    def disable_private_topic_notifications
      uncheck 'user_preferences_form[notify_on_message]'
      click_button I18n.t('thredded.preferences.form.submit_btn')
    end

    def has_private_topic_notifications?
      has_checked_field? 'user_preferences_form[notify_on_message]'
    end

    def has_followed_topic_notifications?
      has_checked_field? 'user_preferences_form[notify_on_followed_activity]'
    end

    def disable_followed_topic_notifications
      uncheck 'user_preferences_form[notify_on_followed_activity]'
      click_button I18n.t('thredded.preferences.form.submit_btn')
    end
  end
end
