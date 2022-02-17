# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'Logged in user' do
  let(:messageboard) { create(:messageboard) }
  let(:topic) do
    topic = create(:topic, with_posts: 1, messageboard: messageboard)
    PageObject::Topic.new(topic)
  end

  def member_signs_in
    user = PageObject::User.new(create(:user, name: 'joel'))
    user.log_in
    user
  end

  it 'can mark a post as unread' do
    member_signs_in

    topic.visit_topic
    post = topic.first_post
    post.mark_unread_from_here
    expect(page).to have_current_path(thredded.messageboard_topics_path(messageboard))
  end

  it "can't mark as unread when not logged in" do
    topic.visit_topic
    expect(page).not_to have_content('Mark unread from here')
  end
end
