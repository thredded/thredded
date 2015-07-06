require 'spec_helper'

feature 'User tracking what they have and have not already read' do
  xscenario 'sees that a new topic is unread' do
    topic = unread_topic
    member_signs_in

    topic.visit_index

    expect(topic).not_to be_read
  end

  xscenario 'sees that a previously read topic is read' do
    topic = unread_topic
    member_signs_in

    topic.visit_index
    topic.view_topic
    topic.visit_index

    expect(topic).to be_read
  end

  xscenario 'sees that an updated topic is unread' do
    topic = unread_topic
    member_signs_in

    topic.view_read_topic
    topic.someone_updates_topic
    topic.visit_index

    expect(topic).not_to be_read
  end

  def unread_topic
    topic = create(:topic, with_posts: 2)
    PageObject::Topics.new(topic.messageboard)
  end

  def member_signs_in
    user = PageObject::User.new(create(:user, name: 'joel'))
    user.log_in
    user
  end
end
