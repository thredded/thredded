require 'spec_helper'

feature 'User editing posts' do
  scenario 'updates post contents' do
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

  scenario 'can edit their own post' do
    user.log_in
    post = users_post
    post.visit_post_edit

    expect(post).to be_editable
  end

  context 'as a admin' do
    scenario "can edit someone else's post" do
      admin.log_in

      post = someone_elses_post
      post.visit_post_edit
      post.submit_new_content('I edited this')

      expect(post).to be_authored_by('sal')
      expect(post).to have_content('I edited this')
    end
  end

  def user
    @user ||= begin
      user = create(:user, name: 'joel')
      PageObject::User.new(user)
    end
  end

  def admin
    @admin ||= begin
      admin = create(:user, :admin, name: 'admin')
      PageObject::User.new(admin)
    end
  end

  def someone_elses_post
    someone_else = create(:user, name: 'sal')
    topic = create(:topic)
    messageboard = topic.messageboard
    post = create(:post, user: someone_else, postable: topic, messageboard: messageboard)
    PageObject::Post.new(post)
  end

  def users_post
    topic = create(:topic)
    messageboard = topic.messageboard
    post = create(:post, user: user.user, postable: topic, messageboard: messageboard)
    PageObject::Post.new(post)
  end
end
