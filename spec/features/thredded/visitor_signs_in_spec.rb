# frozen_string_literal: true
require 'spec_helper'

feature 'Signing in with existing account' do
  let(:user) { PageObject::User.new(create(:user, name: 'joe', email: 'joe@example.com')) }

  scenario 'via the sign in link and form' do
    user.log_in
    expect(user).to be_signed_in
  end

  scenario 'after clicking a follow link follows the topic and shows the followed notice' do
    topic = PageObject::Topic.new(create(:topic, with_posts: 1))
    topic.visit_topic
    topic.follow
    expect(page.status_code).to eq 403
    user.fill_in_sign_in_form_and_submit
    expect(topic).to have_followed_notice
  end
end
