require 'spec_helper'

feature 'User viewing private topics' do
  before do
    PageObject::User.new(user).log_in
  end

  scenario 'sees a list of private topics' do
    private_topics = one_private_topic
    private_topics.visit_index

    expect(private_topics).to have(1).private_topic
  end

  scenario 'reads a private topic and it is marked as read' do
    private_topics = one_private_topic
    private_topics.visit_index

    expect(private_topics).to have(1).private_topic
    expect(private_topics).to have(1).unread_private_topic

    private_topics.view_private_topic
    private_topics.visit_index

    expect(private_topics).to have(0).unread_private_topic
  end

  scenario 'sees that an old topic has been updated' do
    private_topics = one_private_topic
    private_topics.visit_index
    expect(private_topics).to have(1).private_topic
    expect(private_topics).to have(0).unread_private_topic

    private_topics.update_all_private_topics
    private_topics.visit_index

    expect(private_topics).to have(1).unread_private_topic
  end

  scenario 'is notified in the navigation that there are unread topics' do
    navigation = app_navigation
    private_topics = one_private_topic
    private_topics.visit_index

    expect(navigation).to have_unread_private_topics
    expect(private_topics).to have(1).unread_private_topic
  end

  def user
    @user ||= create(:user, name: 'me')
  end

  def one_private_topic
    me = user
    them = create(:user, name: 'them')
    messageboard = create(:messageboard)
    messageboard.add_member(me)
    messageboard.add_member(them)

    create(:private_topic,
      user: me,
      users: [me, them],
      messageboard: messageboard
    )
    PageObject::PrivateTopics.new(messageboard)
  end
end
