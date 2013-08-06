require 'spec_helper'

feature 'A logged in user listing all messageboards' do
  scenario 'can see the public messageboard' do
    user = create(:user)
    public_messageboard = create(:messageboard, :public)

    messageboards = PageObject::Messageboards.new
    messageboards.visit_index_as(user)

    expect(messageboards).to include(public_messageboard)
  end

  scenario 'can not see a private messageboard' do
    user = create(:user)
    private_messageboard = create(:messageboard, :private)

    messageboards = PageObject::Messageboards.new
    messageboards.visit_index_as(user)

    expect(messageboards).not_to include(private_messageboard)
  end

  scenario 'can see the messageboard restricted to those logged in' do
    user = create(:user)
    messageboard = create(:messageboard, :restricted_to_logged_in)

    messageboards = PageObject::Messageboards.new
    messageboards.visit_index_as(user)

    expect(messageboards).to include(messageboard)
  end
end
