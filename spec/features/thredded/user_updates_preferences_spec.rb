# frozen_string_literal: true

require 'spec_helper'
require 'support/features/page_object/notification_preferences'

RSpec.feature 'User updating preferences globally' do
  it 'Allows @ notifications by default' do
    preferences = default_user_preferences

    expect(preferences).to have_at_mention_notifications
  end

  it 'Allows private topic notifications by default' do
    preferences = default_user_preferences

    expect(preferences).to have_notifications_for_private_topics_by_email
  end

  it 'Does not allow private topic notifications' do
    preferences = default_user_preferences
    preferences.disable_notifications_for_private_topics_by_email

    expect(preferences).to be_updated
    expect(preferences).not_to have_notifications_for_private_topics_by_email
  end

  it 'Allows email on post in followed topic by default' do
    preferences = default_user_preferences
    expect(preferences).to have_notifications_for_followed_topics_by_email
  end

  it 'Does not allow followed topic notifications' do
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

  context 'with no notifiers', thredded_reset: [:@notifiers] do
    it 'shows no notifier preferences' do
      Thredded.notifiers = []
      preferences = default_user_preferences
      expect(preferences).not_to have_any_notification_heading_texts
    end
  end
end

RSpec.feature 'User updating preferences for messageboard' do
  it 'Allows @ notifications by default' do
    preferences = default_user_preferences

    expect(preferences).to have_messageboard_at_mention_notifications
  end

  it 'Does not allow @ notifications' do
    preferences = default_user_preferences
    preferences.disable_messageboard_at_mention_notifications

    expect(preferences).to be_updated
    expect(preferences).not_to have_messageboard_at_mention_notifications
  end

  it 'Allows followed topic notifications by default' do
    preferences = default_user_preferences
    expect(preferences).to have_messageboard_notifications_for_followed_topics_by_email
  end

  it 'Does not allow followed topic notifications' do
    preferences = default_user_preferences
    preferences.disable_messageboard_notifications_for_followed_topics_by_email

    expect(preferences).to be_updated
    expect(preferences).not_to have_messageboard_notifications_for_followed_topics_by_email
  end

  context 'with no notifiers', thredded_reset: [:@notifiers] do
    it 'shows no notifier preferences' do
      Thredded.notifiers = []
      preferences = default_user_preferences
      expect(preferences).not_to have_any_notification_heading_texts
    end
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
