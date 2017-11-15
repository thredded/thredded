# frozen_string_literal: true

require 'spec_helper'

feature 'User replying to topic' do
  let!(:posts) { posts_exist_in_a_topic }
  let(:post) { posts.first_post }
  before do
    user.log_in
    expect(page).to have_text("Sign out") # to ensure sign in completes
    posts.visit_posts
  end

  scenario 'adds a new reply' do
    expect { posts.submit_reply }.to change { posts.posts.size }.by(1)
    expect(posts).to have_new_reply
  end

  scenario 'starts a quote-reply (no js)' do
    post.start_quote
    expect(posts.post_form.content).to(start_with('>').and(end_with("\n\n")))
    expect(page).to have_current_path(posts.quote_page_for_first_post)
  end

  scenario 'starts a quote-reply (js)', js: true do
    post.start_quote
    p(content2: posts.post_form.content)
    # Wait for the async quote content fetch completion
    Timeout.timeout(1) do
      loop { print '^';break if posts.post_form.content != '...' }
    end
    p(content: posts.post_form.content)
    expect(posts.post_form.content).to(start_with('>').and(end_with("\n\n")))
    # Expect current path to not have changed because the JS magic takes place
    expect(page).to have_current_path(posts.path)

    # (it's to try stop it from impacting the next spec)
    # TODO: replace this with something more sensible
    puts "sleeping for a long time"
    sleep(10)
    puts "slept for a long time"
  end

  def user
    user = create(:user)
    PageObject::User.new(user)
  end

  def messageboard
    @messageboard ||= create(:messageboard)
  end

  def posts_exist_in_a_topic
    create_list(:post, 10) # just to increase numbers of ids
    topic = create(:topic, messageboard: messageboard)
    posts = create_list(:post, 2, postable: topic, messageboard: messageboard)
    PageObject::Posts.new(posts)
  end
end
