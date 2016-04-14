# frozen_string_literal: true
require 'spec_helper'

feature 'User editing topics' do
  scenario 'can edit their own topic' do
    user.log_in
    topic = users_topic
    topic.visit_topic_edit

    expect(topic).to be_editable
  end

  scenario 'updates topic title' do
    user.log_in
    topic = users_topic
    topic.visit_topic_edit
    topic.change_title_to('this is changed')
    topic.submit

    expect(topic).to have_content('this is changed')
  end

  scenario "cannot edit someone else's topic" do
    user.log_in
    topic = someone_elses_topic
    topic.visit_topic_edit

    expect(topic).not_to be_editable
  end

  context 'as an admin' do
    scenario "can edit someone else's topic" do
      user = admin
      user.log_in
      topic = someone_elses_topic
      topic.visit_topic_edit

      expect(topic).to be_editable

      topic.make_locked
      topic.submit

      expect(topic).to be_locked
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
