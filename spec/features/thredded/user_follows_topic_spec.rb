# frozen_string_literal: true
require 'spec_helper'

feature 'Logged in user' do
  let(:user) { PageObject::User.new(create(:user)) }
  let(:messageboard) { create(:messageboard) }
  let(:an_unfollowed_topic) do
    topic = create(:topic, with_posts: 1, messageboard: messageboard)
    PageObject::Topic.new(topic)
  end
  let(:a_followed_topic) do
    topic = create(:topic, with_posts: 1, messageboard: messageboard)
    Thredded::UserTopicFollow.create_unless_exists(user.user.id, topic.id)
    PageObject::Topic.new(topic)
  end

  before { user.log_in }

  scenario 'can follow a topic' do
    an_unfollowed_topic.visit_topic
    expect(an_unfollowed_topic).to have_follow_button
    an_unfollowed_topic.follow
    expect(an_unfollowed_topic).to_not have_follow_button
    expect(an_unfollowed_topic).to have_unfollow_button
  end

  scenario 'can unfollow a topic' do
    a_followed_topic.visit_topic
    expect(a_followed_topic).to have_unfollow_button
    a_followed_topic.unfollow
    expect(an_unfollowed_topic).to have_follow_button
    expect(an_unfollowed_topic).to_not have_unfollow_button
  end

  context 'with topics' do
    let!(:an_unfollowed_topic) do
      create(:topic, with_posts: 1, messageboard: messageboard)
    end
    let!(:a_followed_topic) do
      topic = create(:topic, with_posts: 1, messageboard: messageboard)
      Thredded::UserTopicFollow.create_unless_exists(user.user.id, topic.id)
      topic
    end
    let(:topics_page) { PageObject::Topics.new(messageboard) }

    scenario 'can see follow status in list of topics' do
      topics_page.visit_index
      expect(find("#topic_#{an_unfollowed_topic.id}")['class']).to include('thredded--topic-notfollowing')
      expect(find("#topic_#{a_followed_topic.id}")['class']).to include('thredded--topic-following')
    end
  end
end
