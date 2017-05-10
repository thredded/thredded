# frozen_string_literal: true

require 'spec_helper'

feature 'User sends a new private topic' do
  scenario 'with title, recipient and content' do
    PageObject::User.new(create(:user, name: 'joel')).log_in
    messageboard = create(:messageboard)
    private_topic = PageObject::PrivateTopics.new(messageboard)
    private_topic.create_private_topic
    private_topic.visit_private_topic_list
    expect(private_topic).to be_on_private_list
  end
end
