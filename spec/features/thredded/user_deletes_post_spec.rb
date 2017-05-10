# frozen_string_literal: true

require 'spec_helper'

feature 'User deleting posts' do
  scenario 'can delete their own post' do
    user.log_in
    topic = users_topic
    topic.visit_topic
    last_post = topic.last_post

    expect(last_post).to be_listed
    expect(last_post).to be_deletable

    last_post.delete

    expect(last_post).not_to be_listed
  end

  scenario 'cannot delete the first post of their own topic' do
    user.log_in
    topic = users_topic
    topic.visit_topic
    expect(topic.first_post).to be_listed
    expect(topic.first_post).not_to be_deletable
  end

  scenario "cannot delete someone else's post" do
    user.log_in
    topic = someone_elses_topic
    topic.visit_topic
    last_post = topic.last_post

    expect(last_post).to be_listed
    expect(last_post).not_to be_deletable
  end

  context 'as an admin' do
    scenario "can delete someone else's post" do
      admin.log_in
      topic = someone_elses_topic
      topic.visit_topic
      last_post = topic.last_post

      expect(last_post).to be_listed
      expect(last_post).to be_deletable

      last_post.delete

      expect(last_post).not_to be_listed
    end

    scenario 'cannot delete the first post of a topic' do
      admin.log_in
      topic = someone_elses_topic
      topic.visit_topic
      expect(topic.first_post).to be_listed
      expect(topic.first_post).not_to be_deletable
    end
  end

  def user
    @user ||= create(:user)
    PageObject::User.new(@user)
  end

  def admin
    @user = create(:user, :admin)
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
