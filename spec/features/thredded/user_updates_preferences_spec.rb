require 'spec_helper'

feature 'User updating preferences' do
  before do
    create_default_config
    create_default_messageboard
    user = create_member_of_messageboard
    sign_in_as(user)
    visit '/users/edit'
    select_default_messageboard
  end

  scenario 'Does now allow @ notifications' do
    click_button 'Update Preferences'

    find('#preference_notify_on_mention').should_not be_checked
  end

  scenario 'Allows @ notifications' do
    check('preference_notify_on_mention')
    click_button 'Update Preferences'

    find('#preference_notify_on_mention').should be_checked
  end

  scenario 'Does not allow private topic notifications' do
    click_button 'Update Preferences'

    find('#preference_notify_on_message').should_not be_checked
  end

  scenario 'Allows private topic notifications' do
    check('preference_notify_on_message')
    click_button 'Update Preferences'

    find('#preference_notify_on_message').should be_checked
  end

  def select_default_messageboard
    within '[data-section="preferences"]' do
      click_button "Submit"
    end
  end

  def create_member_of_messageboard
    default_user.member_of(default_messageboard)
    default_user
  end

  def sign_in_as(user)
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password'
    click_button 'Sign in'
  end
end
