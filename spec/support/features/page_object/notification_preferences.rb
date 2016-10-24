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

    def updated?
      has_content? I18n.t('thredded.preferences.updated_notice')
    end

    def has_at_mention_notifications?
      has_checked_field? 'user_preferences_form[follow_topics_on_mention]'
    end

    def disable_at_notifications
      uncheck 'user_preferences_form[follow_topics_on_mention]'
      click_button I18n.t('thredded.preferences.form.submit_btn')
    end

    def has_notifications_for_private_topics_by_email?
      has_checked_field? 'user_preferences_form[notifications_for_private_topics_attributes][0][enabled]'
      # [0] because email is always first notifier in our tests
    end

    def disable_notifications_for_private_topics_by_email
      uncheck 'user_preferences_form[notifications_for_private_topics_attributes][0][enabled]'
      click_button I18n.t('thredded.preferences.form.submit_btn')
    end

    def has_notifications_for_followed_topics_by_email?
      has_checked_field? 'user_preferences_form[notifications_for_followed_topics_attributes][0][enabled]'
    end

    def disable_notifications_for_followed_topics_by_email
      uncheck 'user_preferences_form[notifications_for_followed_topics_attributes][0][enabled]'
      click_button I18n.t('thredded.preferences.form.submit_btn')
    end

    def has_messageboard_at_mention_notifications?
      has_checked_field? 'user_preferences_form[messageboard_follow_topics_on_mention]'
    end

    def disable_messageboard_at_mention_notifications
      uncheck 'user_preferences_form[messageboard_follow_topics_on_mention]'
      click_button I18n.t('thredded.preferences.form.submit_btn')
    end

    def has_messageboard_notifications_for_followed_topics_by_email?
      has_checked_field? 'user_preferences_form[messageboard_notifications_for_followed_topics_attributes][0][enabled]'
    end

    def disable_messageboard_notifications_for_followed_topics_by_email
      uncheck 'user_preferences_form[messageboard_notifications_for_followed_topics_attributes][0][enabled]'
      click_button I18n.t('thredded.preferences.form.submit_btn')
    end

    def has_any_notification_heading_texts?
      [
        I18n.t('thredded.preferences.form.notifications_for_followed_topics.label'),
        I18n.t('thredded.preferences.form.notifications_for_private_topics.label'),
        I18n.t('thredded.preferences.form.messageboard_notifications_for_followed_topics.label')
      ].any? do |text|
        has_content?(text)
      end
    end
  end
end
