# frozen_string_literal: true
module PageObject
  class User
    include Capybara::DSL
    include Authentication
    include Rails.application.routes.url_helpers
    include FactoryGirl::Syntax::Methods

    attr_accessor :user

    def initialize(user)
      @user = user
    end

    def log_in
      visit new_user_session_path
      fill_in 'name', with: user.name
      uncheck 'Admin' unless user.admin?
      click_button 'Sign in'
    end

    def load_page
      visit Thredded.user_path(nil, @user)
    end

    def displaying_the_profile?
      has_content?(@user.thredded_display_name)
    end

    def has_redirected_with_error?
      has_content?("No user exists named #{@user.name}")
    end
  end
end
