require 'spec_helper'

feature 'Anonymous user visiting messageboard' do
  scenario 'can view topics when messageboard is publicly readable' do
    public_messageboard = create(:messageboard, :public)
    messageboards = PageObject::Messageboards.new
    messageboards.visit_index

    expect(messageboards).to include(public_messageboard)
  end

  scenario 'can not see a messageboard when it is private' do
    private_messageboard = create(:messageboard, :private)
    messageboards = PageObject::Messageboards.new
    messageboards.visit_index

    expect(messageboards).not_to include(private_messageboard)
  end

  scenario 'can not see a messageboard when it is for logged in users only' do
    board_for_logged_in_users = create(:messageboard, :restricted_to_logged_in)
    messageboards = PageObject::Messageboards.new
    messageboards.visit_index

    expect(messageboards).not_to include(board_for_logged_in_users)
  end
end
