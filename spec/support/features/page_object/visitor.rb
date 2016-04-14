# frozen_string_literal: true
require_relative './authentication'

module PageObject
  class Visitor
    include Capybara::DSL
    include Authentication
    include Thredded::Engine.routes.url_helpers

    attr_accessor :visitor

    def initialize
      @visitor = ::User.new(name: 'anonymous', email: 'anon@email.com')
    end

    def has_redirected_with_error?
      has_content?("No user exists named #{@visitor}")
    end

    def links_github_with_existing_account
      visit edit_user_registration_path
      fill_in 'identity_email', with: 'joel@example.com'
      fill_in 'identity_password', with: 'password'
      find('#identity_submit').click
    end

    def load_page
      visit user_path(@visitor)
    end

    def seeing_notice_to_link_account?
      has_content? 'If you would like to link'
    end

    def signed_in_as_previous_user?
      find('#user_email').value.should == 'joel@example.com'
    end

    def able_to_link_account?
      goes_to_edit_account
      has_css? 'legend', text: 'Link Your Account'
    end

    def visits_the_latest_thread_on(messageboard)
      topic = messageboard.topics.order('id desc').first
      visit messageboard_topic_path(messageboard, topic)
    end

    def on_latest_thread_on?(messageboard)
      topic = messageboard.topics.order('id desc').first
      find('header .breadcrumbs').has_content?(topic.title)
    end

    def submits_email_address
      fill_in 'user_email', with: 'joel@example.com'
      find('.submit input').click
    end
  end
end
