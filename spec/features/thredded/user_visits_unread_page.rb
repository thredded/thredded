# frozen_string_literal: true

require 'spec_helper'

feature 'User viewing unread topics' do
  let(:user) { create(:user) }
  let(:messageboard) { create(:messageboard) }

  scenario 'sees unread topics, sorted followed-first' do
    create_topic(title: 'Read topic', read: true)
    create_topic(title: 'Read followed topic', read: true, followed: true)
    unread_topic = create_topic(title: 'Unread topic')
    unread_followed_topic = create_topic(title: 'Unread followed topic', followed: true)

    topics = PageObject::Topics.new(messageboard)
    nav = PageObject::Navigation.new
    PageObject::User.new(user).log_in
    topics.visit_index
    expect(nav.unread_followed_topics_count).to eq(1)
    nav.click_unread
    expect(topics.displayed_titles)
      .to eq [
        unread_followed_topic.title,
        unread_topic.title,
      ]
  end

  def create_topic(title:, read: false, followed: false)
    topic = create(:topic, with_posts: 1, messageboard: messageboard, title: title)
    create(:user_topic_read_state, user: user, postable: topic, read_at: topic.updated_at) if read
    create(:user_topic_follow, user: user, topic: topic) if followed
    topic
  end
end
