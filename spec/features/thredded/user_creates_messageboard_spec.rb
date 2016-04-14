# frozen_string_literal: true
require 'spec_helper'

feature 'Creating a messageboard' do
  scenario 'admin bootstraps the app' do
    user = an_admin
    user.log_in

    create_board = set_up_a_messageboard
    create_board.visit_messageboard_list
    create_board.click_new_messageboard
    create_board.submit_form

    expect(create_board).to be_done
    expect(user).to be_logged_in
  end

  scenario 'regular user does not see the new messageboard link' do
    user = regular_user
    user.log_in
    expect(user).to be_logged_in

    create_board = set_up_a_messageboard
    create_board.visit_messageboard_list

    expect(create_board).not_to have_a_new_messageboard_link
  end

  scenario 'regular user is shown an Unauthorized message if trying to directly access form' do
    user = regular_user
    user.log_in
    expect(user).to be_logged_in

    create_board = set_up_a_messageboard
    create_board.visit_new_messageboard_form

    expect(create_board).to be_on_access_forbidden_page
  end

  def set_up_a_messageboard
    PageObject::NewMessageboard.new
  end

  def an_admin
    PageObject::User.new(create(:user, name: 'joe-admin', admin: true))
  end

  def regular_user
    PageObject::User.new(create(:user, name: 'joe'))
  end
end
