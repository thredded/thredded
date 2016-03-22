require 'spec_helper'

feature 'User deleting topics' do
  scenario 'cannot delete their own topic' do
    user.log_in
    topic = users_topic
    topic.visit_topic

    expect(topic).to_not be_deletable
  end

  context 'as a superadmin' do
    scenario "can delete someone else's topic" do
      superadmin.log_in
      topic = someone_elses_topic
      topic.visit_topic

      expect(topic).to be_deletable

      topic.delete

      expect(topic).to have_redirected_after_delete
      expect(topic).to_not be_listed
    end
  end

  def user
    @user ||= create(:user)
    PageObject::User.new(@user)
  end

  def superadmin
    @user = create(:user, :superadmin)
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
