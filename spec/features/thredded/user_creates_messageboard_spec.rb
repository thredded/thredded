require 'spec_helper'

feature 'Creating a messageboard' do
  scenario 'superadmin bootstraps the app' do
    user = a_superadmin
    user.signs_in_as('joe')

    create_board = set_up_a_messageboard
    create_board.visit_messageboard_list
    create_board.click_new_messageboard
    create_board.submit_form

    expect(create_board).to be_done
    expect(user).to be_logged_in
  end

  scenario 'regular user does not see the new messageboard link' do
    user = regular_user
    user.signs_in_as('joe')
    expect(user).to be_logged_in

    create_board = set_up_a_messageboard
    create_board.visit_messageboard_list

    expect(create_board).not_to have_a_new_messageboard_link
  end

  scenario 'regular user is redirected if trying to directly access form' do
    user = regular_user
    user.signs_in_as('joe')
    expect(user).to be_logged_in

    create_board = set_up_a_messageboard
    create_board.visit_new_messageboard_form

    expect(create_board).to be_on_the_messageboard_list
  end

  def set_up_a_messageboard
    PageObject::NewMessageboard.new
  end

  def a_superadmin
    PageObject::Owner.new
  end

  def regular_user
    PageObject::User.new(create(:user, name: 'joe'))
  end
end
