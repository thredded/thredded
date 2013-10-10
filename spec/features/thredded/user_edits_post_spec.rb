require 'spec_helper'
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

feature 'User editing posts' do
  scenario 'can edit their own post' do
    user.log_in
    post = users_post
    post.visit_post_edit

    expect(post).to be_editable
    expect(post).to have_markdown_as_the_filter
  end

  scenario 'updates post contents', js: true do
    user.log_in
    post = users_post
    post.visit_post_edit
    post.change_content_to('this is changed')
    expect(post).to have_content('this is changed')
  end

  scenario "cannot edit someone else's post" do
    user.log_in
    post = someone_elses_post
    post.visit_post_edit

    expect(post).not_to be_editable
  end

  scenario 'sees the post retain its original filter' do
    user.log_in
    post = users_post_with_bbcode
    post.visit_post_edit

    expect(post).to have_bbcode_as_the_filter
  end

  context 'as a superadmin' do
    scenario "can edit someone else's post" do
      user = superadmin
      user.log_in
      post = someone_elses_post
      post.visit_post_edit

      expect(post).to be_editable
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

  def someone_elses_post
    someone_else = create(:user)
    topic = create(:topic)
    messageboard = topic.messageboard
    post = create(:post, user: someone_else, topic: topic, messageboard: messageboard)
    PageObject::Post.new(post)
  end

  def users_post
    topic = create(:topic)
    messageboard = topic.messageboard
    post = create(:post, user: @user, topic: topic, messageboard: messageboard)
    PageObject::Post.new(post)
  end

  def users_post_with_bbcode
    topic = create(:topic)
    messageboard = topic.messageboard
    post = create(:post,
      user: @user,
      topic: topic,
      messageboard: messageboard,
      filter: 'bbcode',
    )
    PageObject::Post.new(post)
  end
end
