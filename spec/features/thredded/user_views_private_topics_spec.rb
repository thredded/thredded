# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'User viewing private topics' do
  before do
    PageObject::User.new(user).log_in
  end

  it 'sees a list of private topics' do
    private_topics = one_private_topic
    private_topics.visit_index

    expect(private_topics.private_topics.size).to eq(1)
  end

  it 'reads a private topic and it is marked as read' do
    private_topics = one_private_topic
    private_topics.visit_index

    expect(private_topics.private_topics.size).to eq(1)
    expect(private_topics.unread_private_topics.size).to eq(1)

    private_topics.view_private_topic
    private_topics.visit_index

    expect(private_topics.unread_private_topics.size).to eq(0)
  end

  it 'sees that an old topic has been updated' do
    private_topics = one_private_topic
    private_topics.visit_index
    private_topics.view_private_topic
    private_topics.visit_index

    expect(private_topics.private_topics.size).to eq(1)
    expect(private_topics.unread_private_topics.size).to eq(0)

    travel_to 1.minute.from_now do
      private_topics.someone_updates_topic
    end
    private_topics.visit_index

    expect(private_topics.private_topics.size).to eq(1)
    expect(private_topics.unread_private_topics.size).to eq(1)
  end

  it 'is notified in the navigation that there are unread topics' do
    navigation = app_navigation
    private_topics = one_private_topic
    private_topics.visit_index

    expect(navigation).to have_unread_private_topics
    expect(private_topics.unread_private_topics.size).to eq(1)

    private_topics.view_private_topic
    private_topics.visit_index

    expect(navigation).not_to have_unread_private_topics
  end

  def user
    @user ||= create(:user, name: 'me')
  end

  def one_private_topic
    me = user
    them = create(:user, name: 'them')

    private_topic = create(
      :private_topic,
      user: me,
      users: [me, them],
      posts: build_list(:private_post, 1)
    )
    PageObject::PrivateTopics.new(private_topic.title)
  end

  def app_navigation
    @app_navigation ||= PageObject::Navigation.new
  end
end
