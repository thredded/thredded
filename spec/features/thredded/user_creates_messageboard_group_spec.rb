# frozen_string_literal: true
require 'spec_helper'

feature 'Creating a messageboard group' do
  scenario 'admin creates a unique messageboard group' do
    user = an_admin
    user.log_in

    group = set_up_a_messageboard_group
    group.visit_new_messageboard_group_form
    group.submit_form

    expect(group).to be_created
  end

  scenario 'admin creates non unique messageboard group' do
    user = an_admin
    user.log_in

    group = set_up_a_messageboard_group
    group.create_messageboard_group
    group.visit_new_messageboard_group_form
    group.submit_form

    expect(group).to be_duplicate
  end

  def set_up_a_messageboard_group
    PageObject::NewMessageboardGroup.new
  end

  def an_admin
    PageObject::User.new(create(:user, name: 'joe-admin', admin: true))
  end
end
