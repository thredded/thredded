# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'Creating a messageboard group' do
  it 'admin can visit particular groups' do
    user = an_admin
    user.log_in
    group_1 = create_a_messageboard_group('FirstGroup')
    group_2 = create_a_messageboard_group('SecondGroup')

    group_1.visit_messageboard_group
    expect(page).to have_content group_1.name
    expect(page).not_to have_content group_2.name
    expect(page).to have_content group_1.a_messageboard.name

    group_2.visit_messageboard_group
    expect(page).to have_content group_2.name
    expect(page).not_to have_content group_1.name
    expect(page).to have_content group_2.a_messageboard.name
  end

  def create_a_messageboard_group(name)
    PageObject::MessageboardGroup.new(name)
  end

  def an_admin
    PageObject::User.new(create(:user, name: 'joe-admin', admin: true))
  end
end
