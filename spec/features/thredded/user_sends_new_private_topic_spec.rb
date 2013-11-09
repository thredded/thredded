require 'spec_helper'

feature 'User sends a new private topic' do
  scenario 'with title, recipient and content' do
    private_topic = new_private_topic

    private_topic.create_private_topic
    expect(private_topic).not_to be_on_public_list

    private_topic.visit_private_topic_list
    expect(private_topic).to be_on_private_list
  end

  def new_private_topic
    sign_in

    messageboard = create(:messageboard)
    messageboard.add_member(user)
    messageboard.add_member(other_user)

    PageObject::PrivateTopics.new(messageboard)
  end

  def sign_in
    PageObject::User.new(user).log_in
  end

  def user
    @user ||= create(:user, name: 'joel')
  end

  def other_user
    @other_user ||= create(:user, name: 'carl')
  end
end
