# frozen_string_literal: true
require 'spec_helper'

feature 'Logged in user' do
  let(:user) { PageObject::User.new(create(:user)) }
  let(:an_unfollowed_topic) do
    topic = create(:topic, with_posts: 1, messageboard: create(:messageboard))
    PageObject::Topic.new(topic)
  end
  let(:a_followed_topic) do
    topic = create(:topic, with_posts: 1, messageboard: create(:messageboard))
    Thredded::UserTopicFollow.create_unique(user.user.id, topic.id)
    PageObject::Topic.new(topic)
  end

  before { user.log_in }

  scenario 'can follow a topic' do
    an_unfollowed_topic.visit_topic
    expect(page).to have_button('Follow')
    click_on 'Follow'
    expect(page).to_not have_button('Follow')
  end

  scenario 'can unfollow a topic' do
    a_followed_topic.visit_topic
    expect(page).to have_button('Stop following')
    click_on 'Stop following'
    expect(page).to_not have_button('Stop following')
  end

  scenario 'can see follow status in list of topics'

end
