# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'Creating a messageboard group' do
  it 'admin creates a unique messageboard group' do
    user = an_admin
    user.log_in

    group = set_up_a_messageboard_group
    group.visit_new_messageboard_group_form
    group.submit_form

    expect(group).to be_created
  end

  it 'admin creates non unique messageboard group' do
    user = an_admin
    user.log_in

    group = set_up_a_messageboard_group
    group.visit_new_messageboard_group_form
    group.submit_form_with_duplicate_group_name

    expect(group).to have_duplicate_messageboard_group_error
  end

  def set_up_a_messageboard_group
    PageObject::NewMessageboardGroup.new
  end

  def an_admin
    PageObject::User.new(create(:user, name: 'joe-admin', admin: true))
  end
end
