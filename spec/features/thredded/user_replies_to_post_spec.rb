# frozen_string_literal: true
require 'spec_helper'

feature 'User replying to topic' do
  let(:posts) { posts_exist_in_a_topic }
  let(:post) { posts.first_post }
  before do
    user.log_in
    posts.visit_posts
  end

  scenario 'adds a new reply' do
    expect { posts.submit_reply }.to change { posts.posts.size }.by(1)
    expect(posts).to have_new_reply
  end

  scenario 'starts a quote-reply (no js)' do
    post.start_quote
    expect(page).to have_current_path(posts.quote_page_for_first_post)
    expect(posts.post_form.content).to(start_with('>').and(end_with("\n\n")))
  end

  scenario 'starts a quote-reply (js)', js: true do
    post.start_quote
    # Expect current path to not change because the JS magic takes place
    expect(page).to have_current_path(current_path)
    # Wait for the async quote content fetch completion
    Timeout.timeout(1) do
      loop { break if posts.post_form.content != '...' }
    end
    expect(posts.post_form.content).to(start_with('>').and(end_with("\n\n")))
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
    posts = create_list(:post, 2, postable: topic, messageboard: messageboard)
    PageObject::Posts.new(posts)
  end
end
