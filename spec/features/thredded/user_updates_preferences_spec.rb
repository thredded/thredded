require 'spec_helper'
require 'support/features/page_object/messageboard_preferences'

feature 'User updating preferences' do
  scenario 'Allows @ notifications by default' do
    preferences = default_user_preferences

    expect(preferences).to have_at_mention_notifications
  end

  scenario 'Does not allow @ notifications' do
    preferences = default_user_preferences
    preferences.disable_at_notifications

    expect(preferences).to be_updated
    expect(preferences).not_to have_at_mention_notifications
  end

  scenario 'Allows private topic notifications by default' do
    preferences = default_user_preferences

    expect(preferences).to have_private_topic_notifications
  end

  scenario 'Does not allow private topic notifications' do
    preferences = default_user_preferences
    preferences.disable_private_topic_notifications

    expect(preferences).to be_updated
    expect(preferences).to_not have_private_topic_notifications
  end

  def default_user_preferences
    user = create(:user)
    default_user_preferences = PageObject::MessageboardPreferences.new(user)
    default_user_preferences.visit_preferences
    default_user_preferences
  end
end
