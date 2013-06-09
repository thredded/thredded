require 'spec_helper'

feature 'Signing up' do
  scenario 'Visitor signs up' do
    create_default_config
    create(:messageboard)
    visit new_user_registration_path
    fill_in 'user_name', with: 'john'
    fill_in 'user_email', with: 'john@email.com'
    fill_in 'user_password', with: 'password'
    fill_in 'user_password_confirmation', with: 'password'
    click_button 'Sign up'

    page.should have_content('You have signed up successfully.')
  end
end
