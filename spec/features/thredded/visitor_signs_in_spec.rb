# frozen_string_literal: true
require 'spec_helper'

feature 'Signing in' do
  scenario 'Visitor with existing account signs in' do
    create(:user, name: 'joe', email: 'joe@example.com')
    visit new_session_path
    fill_in 'name', with: 'joe'
    click_button 'Sign in'

    expect(page).to have_content('joe')
    expect(page).to have_content('Sign out')
  end
end
