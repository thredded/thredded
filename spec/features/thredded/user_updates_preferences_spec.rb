# frozen_string_literal: true
require 'spec_helper'
require 'support/features/page_object/notification_preferences'

feature 'User updating preferences globally' do
  scenario 'Allows @ notifications by default' do
    preferences = default_user_preferences

    expect(preferences).to have_at_mention_notifications
  end

  scenario 'Allows private topic notifications by default' do
    preferences = default_user_preferences

    expect(preferences).to have_notifications_for_private_topics_by_email
  end

  scenario 'Does not allow private topic notifications' do
    preferences = default_user_preferences
    preferences.disable_notifications_for_private_topics_by_email

    expect(preferences).to be_updated
    expect(preferences).not_to have_notifications_for_private_topics_by_email
  end

  scenario 'Allows email on post in followed topic by default' do
    preferences = default_user_preferences
    expect(preferences).to have_notifications_for_followed_topics_by_email
  end

  scenario 'Does not allow followed topic notifications' do
    preferences = default_user_preferences
    preferences.disable_notifications_for_followed_topics_by_email

    expect(preferences).to be_updated
    expect(preferences).not_to have_notifications_for_followed_topics_by_email
  end

  def default_user_preferences
    user = create(:user)
    default_user_preferences =
      PageObject::NotificationPreferences.new(user, nil)
    default_user_preferences.visit_notification_edit
    default_user_preferences
  end
end

feature 'User updating preferences for messageboard' do
  scenario 'Allows @ notifications by default' do
    preferences = default_user_preferences

    expect(preferences).to have_messageboard_at_mention_notifications
  end

  scenario 'Does not allow @ notifications' do
    preferences = default_user_preferences
    preferences.disable_messageboard_at_mention_notifications

    expect(preferences).to be_updated
    expect(preferences).not_to have_messageboard_at_mention_notifications
  end

  scenario 'Allows followed topic notifications by default' do
    preferences = default_user_preferences
    expect(preferences).to have_messageboard_notifications_for_followed_topics_by_email
  end

  scenario 'Does not allow followed topic notifications' do
    preferences = default_user_preferences
    preferences.disable_messageboard_notifications_for_followed_topics_by_email

    expect(preferences).to be_updated
    expect(preferences).not_to have_messageboard_notifications_for_followed_topics_by_email
  end

  def default_user_preferences
    user = create(:user)
    messageboard = create(:messageboard)

    default_user_preferences =
      PageObject::NotificationPreferences.new(user, messageboard)
    default_user_preferences.visit_notification_edit
    default_user_preferences
  end
end
