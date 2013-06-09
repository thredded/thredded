require 'spec_helper'

feature 'Visitor authenticates w/Oauth' do
  before do
    create(:app_config)
    create_messageboard
  end

  scenario 'Signs up and signs in with GitHub' do
    visitor = the_new_visitor
    visitor.signs_up_via_github

    expect(visitor).to be_logged_in
    expect(visitor).to be_seeing_notice_to_link_account
  end

  scenario 'Signs in with GitHub and can link account' do
    visitor = the_new_visitor
    visitor.signs_up_via_github

    expect(visitor).to be_able_to_link_account
  end

  scenario 'Signs in with Github and links previous account' do
    user = the_previous_user
    visitor = the_new_visitor
    visitor.signs_up_via_github
    visitor.links_github_with_existing_account

    expect(visitor).to be_logged_in
    expect(visitor).to be_signed_in_as_previous_user
    expect(visitor).to_not be_able_to_link_account
  end

  scenario 'After linking account user should be able to log out and in with right account' do
    user = the_previous_user
    visitor = the_new_visitor
    visitor.signs_up_via_github
    visitor.links_github_with_existing_account
    visitor.signs_out
    visitor.signs_up_via_github
    visitor.goes_to_edit_account

    expect(visitor).to be_signed_in_as_previous_user
  end

  scenario 'Signs in through a topic on a board postable by anyone logged in' do
    visitor = the_new_visitor
    visitor.visits_the_latest_thread_on(messageboard)
    visitor.clicks_github_sign_in_link

    expect(visitor).to be_logged_in
    expect(visitor).to be_on_latest_thread_on(messageboard)
  end

  scenario 'Tries to sign up without an email address at GitHub' do
    mock_github_without_email
    visitor = the_new_visitor
    visitor.signs_up_via_github

    expect(visitor).to_not be_logged_in
    expect(page).to have_content('You have no email')
    expect(page).to have_css('input#user_email')

    visitor.submits_email_address
    expect(visitor).to be_logged_in
  end

  def messageboard
    @messageboard ||= begin
      messageboard = create_default_messageboard
      messageboard.update_attribute(:posting_permission, 'logged_in')
      create(:topic, messageboard: messageboard, with_posts: 2)
      messageboard
    end
  end

  alias create_messageboard messageboard

  def the_previous_user
    @the_previous_user ||= create(:user, email: 'joel@example.com', password: 'password')
  end

  def the_new_visitor
    PageObject::Visitor.new
  end

  def mock_github_without_email
    OmniAuth.config.mock_auth[:github] = {
      'uid' => '12345',
      'provider' => 'github',
      'info' => {
        'nickname' => 'foobar',
        'name' => 'Foo Bar'
      }
    }
  end
end
