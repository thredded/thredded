require 'spec_helper'

feature 'User starring a topic' do
  scenario 'sees a list of unstarred topics' do
    topics = three_topics
    topics.visit_index

    expect(topics).to have(0).starred_topics
  end

  scenario 'views an unstarred topic' do
    topics = three_topics
    topic = topics.visit_latest_topic

    expect(topic).to be_able_to_star
    expect(topic).to be_rated_as(0)
  end

  scenario 'stars a topic' do
    topics = three_topics
    topic = topics.visit_latest_topic
    topic.star_topic

    expect(topic).to be_rated_as(1)
    expect(topic).to be_able_to_unstar

    topics.visit_index

    expect(topics).to have(1).starred_topics
  end

  scenario 'unstars a topic' do
    topics = three_topics
    topics.visit_latest_topic
    topic.star_topic
    topic.unstar_topic

    expect(topic).to be_able_to_star
    expect(topic).to be_rated_as(0)

    topics.visit_index

    expect(topics).to have(0).starred_topics
  end

  scenario "cannot star a user's own topic" do
    user.log_in
    topic = users_topic
    topic.visit_topic

    expect(topic).to_not be_able_to_star
  end

  scenario "can star another user's topic" do
    user.log_in
    topic = someone_elses_topic
    topic.visit_topic

    expect(topic).to be_able_to_star
  end

  scenario 'adds a star to a topic with stars' do
    topic = someone_elses_topic
    user.log_in
    topic.visit_topic
    topic.star_topic
    user.log_out
    another_user.log_in
    topic.visit_topic

    expect(topic).to be_rated_as(1)

    topic.star_topic

    expect(topic).to be_rated_as(2)
  end

  def three_topics
    @three_topics ||= begin
      messageboard = create(:messageboard)
      create_list(:topic, 3, messageboard: messageboard)
      PageObject::Topics.new(messageboard)
    end
  end

  def user
    @user ||= create(:user)
    PageObject::User.new(@user)
  end

  def another_user
    @another_user ||= create(:user)
    PageObject::User.new(@user)
  end

  def users_topic
    topic = create(:topic, with_posts: 3, user: @user)
    PageObject::Topic.new(topic)
  end

  def someone_elses_topic
    topic = create(:topic, with_posts: 2)
    PageObject::Topic.new(topic)
  end
end
