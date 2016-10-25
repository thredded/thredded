# frozen_string_literal: true
require 'spec_helper'

feature 'Signing in with existing account' do
  let(:user) { PageObject::User.new(create(:user, name: 'joe', email: 'joe@example.com')) }

  scenario 'directly' do
    user.log_in
    expect(user).to be_signed_in
  end

  scenario 'after clicking a follow link' do
    PageObject::Topic.new(create(:topic, with_posts: 1)).visit_topic
    click_button I18n.t('thredded.topics.follow')
    expect(page.status_code).to eq 403
    user.fill_in_sign_in_form_and_submit
    expect(page).to have_text(I18n.t('thredded.topics.followed_notice'))
  end
end
