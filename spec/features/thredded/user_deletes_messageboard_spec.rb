# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'Deleting a messageboard' do
  describe 'with show_messageboard_delete_button set to true', js: true do
    around do |example|
      with_thredded_setting(:show_messageboard_delete_button, true, &example)
    end

    it 'succeeds' do
      messageboard = a_messageboard
      user = an_admin
      user.log_in
      messageboard.visit_messageboard_edit
      expect(messageboard).to be_deletable

      messageboard.delete

      expect(messageboard).to have_redirected_after_delete
      expect(messageboard).not_to be_listed
    end
  end

  describe 'with show_messageboard_delete_button set to false' do
    around do |example|
      with_thredded_setting(:show_messageboard_delete_button, false, &example)
    end

    it 'does not have delete button' do
      messageboard = a_messageboard
      user = an_admin
      user.log_in
      messageboard.visit_messageboard_edit

      expect(messageboard).not_to be_deletable
    end
  end

  def an_admin
    PageObject::User.new(create(:user, name: 'joe-admin', admin: true))
  end

  def a_messageboard
    messageboard = create(:messageboard)
    PageObject::MessageBoard.new(messageboard)
  end
end
