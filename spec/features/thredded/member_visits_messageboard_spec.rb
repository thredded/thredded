require 'spec_helper'

feature 'A logged in member of a messageboard listing all messageboards' do
  context 'and a messageboard is private' do
    scenario 'can see the messageboard when they are a member' do
      user = create(:user)
      private_messageboard = create(:messageboard, :private)
      private_messageboard.add_member(user)

      messageboards = PageObject::Messageboards.new
      messageboards.visit_index_as(user)

      expect(messageboards).to include(private_messageboard)
    end

    scenario 'cannot see the messageboard when they are not a member' do
      user = create(:user)
      other_messageboard = create(:messageboard)
      other_messageboard.add_member(user)
      private_messageboard = create(:messageboard, :private)

      messageboards = PageObject::Messageboards.new
      messageboards.visit_index_as(user)

      expect(messageboards).not_to include(private_messageboard)
    end
  end

  scenario 'can see a messageboard when it is publicly readable' do
    user = create(:user)
    other_messageboard = create(:messageboard)
    other_messageboard.add_member(user)
    public_messageboard = create(:messageboard, :public)

    messageboards = PageObject::Messageboards.new
    messageboards.visit_index_as(user)

    expect(messageboards).to include(public_messageboard)
  end

  scenario 'can see a messageboard when it is for logged in users' do
    user = create(:user)
    other_messageboard = create(:messageboard)
    other_messageboard.add_member(user)
    board_for_logged_in_users = create(:messageboard, :restricted_to_logged_in)

    messageboards = PageObject::Messageboards.new
    messageboards.visit_index_as(user)

    expect(messageboards).to include(board_for_logged_in_users)
  end
end
