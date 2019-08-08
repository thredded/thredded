require 'spec_helper'

RSpec.feature 'Deleting a messageboard' do
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

  def an_admin
    PageObject::User.new(create(:user, name: 'joe-admin', admin: true))
  end

  def a_messageboard
    messageboard = create(:messageboard)
    PageObject::MessageBoard.new(messageboard)
  end
end