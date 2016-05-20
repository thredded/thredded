# frozen_string_literal: true
require 'spec_helper'

feature 'Editing a messageboard' do
  scenario 'succeeds' do
    messageboard = create(:messageboard)
    PageObject::User.new(create(:user, name: 'joe-admin', admin: true)).log_in
    visit thredded.messageboard_topics_path(messageboard)
    click_link I18n.t('thredded.nav.edit_messageboard')
    new_name = messageboard.name + '1'
    fill_in 'messageboard_name', with: new_name
    click_button I18n.t('thredded.messageboard.update')
    expect(page).to have_content(new_name)
  end
end
