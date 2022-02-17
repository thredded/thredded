# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'User visits profile page of another user' do
  let(:user) { create(:user) }
  let(:messageboard) { create(:messageboard) }

  it 'sees private message link and recent posts by that user' do
    another_user = create(:user)
    create(:post, user: another_user, content: 'Post by another user')

    PageObject::User.new(user).log_in
    visit user_path(another_user.id)

    profile = PageObject::Profile.new
    expect(profile).to have_send_private_message_link
    expect(profile).to have_post_with_content('Post by another user')
  end
end
