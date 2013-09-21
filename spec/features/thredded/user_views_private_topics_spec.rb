require 'spec_helper'

feature 'User viewing topics' do
  before do
    PageObject::User.new(user).log_in
  end

  scenario 'sees a list of private topics' do
    private_topics = one_private_topic
    private_topics.visit_index

    expect(private_topics).to have(1).private_topic
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
