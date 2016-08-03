# frozen_string_literal: true
require 'spec_helper'

feature 'User views a topic' do
  let(:user) { create(:user) }
  let(:messageboard) { create(:messageboard) }

  context 'for a followed topic' do
    let(:a_followed_topic) do
      topic = create(:topic, with_posts: 1, messageboard: messageboard)
      Thredded::UserTopicFollow.create_unless_exists(user.id, topic.id)
      PageObject::Topic.new(topic)
    end

    scenario 'can see list of users following topic' do
      a_followed_topic.visit_topic
      within '.thredded--topic-header' do
        expect(page).to have_content(user.name)
      end
    end
  end

  context 'for an unfollowed topic' do
    let(:a_unfollowed_topic) do
      topic = create(:topic, messageboard: messageboard)
      PageObject::Topic.new(topic)
    end

    scenario 'can see that no one is following' do
      a_unfollowed_topic.visit_topic
      within '.thredded--topic-header' do
        expect(page).to have_content('No one is following this topic')
      end
    end
  end
end
