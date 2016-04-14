# frozen_string_literal: true
require 'spec_helper'

feature 'User deleting topics' do
  scenario 'cannot delete their own topic' do
    user.log_in
    topic = users_topic
    topic.visit_topic

    expect(topic).not_to be_deletable
  end

  context 'as an admin' do
    scenario "can delete someone else's topic" do
      admin.log_in
      topic = someone_elses_topic
      topic.visit_topic

      expect(topic).to be_deletable

      topic.delete

      expect(topic).to have_redirected_after_delete
      expect(topic).not_to be_listed
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
