# frozen_string_literal: true
require 'spec_helper'

feature 'Logged in user' do
  let(:user) { create(:user, name: 'sally') }
  let(:other_user) { create(:user, name: 'jane') }
  let(:messageboard) { create(:messageboard) }
  let(:private_topic) { create(:private_topic, user: user, users: [user, other_user]) }
  let(:private_topic_page) { PageObject::PrivateTopic.new(private_topic) }

  let!(:private_post) { create(:private_post, postable: private_topic, user: user) }

  def member_signs_in
    page_user = PageObject::User.new(user)
    page_user.log_in
    page_user
  end

  scenario 'can mark a post as unread' do
    member_signs_in

    visit thredded.private_topic_path(private_topic)
    private_topic_page.mark_unread_from_here
    expect(page.current_path).to eq thredded.private_topics_path
  end
end
