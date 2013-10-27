require 'spec_helper'

feature 'User replying to topic' do
  scenario 'adds a new reply' do
    user.log_in

    posts = posts_exist_in_a_topic
    posts.visit_posts
    expect(posts).to have(2).posts

    posts.submit_reply
    expect(posts).to have(3).posts
    expect(posts).to have_new_reply
  end

  def user
    user = create(:user)
    PageObject::User.new(user)
  end

  def messageboard
    @messageboard ||= create(:messageboard)
  end

  def posts_exist_in_a_topic
    topic = create(:topic, messageboard: messageboard)
    posts = create_list(:post, 2, topic: topic, messageboard: messageboard)
    PageObject::Posts.new(posts)
  end
end
