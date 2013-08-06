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

  scenario 'replies with the bbcode filter' do
    user.log_in

    posts = posts_exist_in_a_topic
    posts.visit_posts
    posts.use_bbcode
    posts.submit_reply('[b]Word[/b]')

    expect(posts).to have_a_bold('Word')
  end

  scenario 'defaults the post filter to markdown' do
    posts = posts_exist_in_a_topic
    user.log_in

    posts.visit_posts

    expect(posts).to have_markdown_as_default_filter
  end

  scenario 'defaults the post filter to bbcode' do
    posts = posts_exist_in_a_topic
    user_with_a_bbcode_filter_preference.log_in

    posts.visit_posts

    expect(posts).to have_bbcode_as_default_filter
  end

  def posts_exist_in_a_topic
    topic = create(:topic, messageboard: messageboard)
    posts = create_list(:post, 2, topic: topic, messageboard: messageboard)
    PageObject::Posts.new(posts)
  end

  def user
    user = create(:user)
    PageObject::User.new(user)
  end

  def user_with_a_bbcode_filter_preference
    user = create(:user, :prefers_bbcode)
    PageObject::User.new(user)
  end

  def messageboard
    @messageboard ||= create(:messageboard)
  end
end
