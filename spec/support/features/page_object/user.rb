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
      fill_in_sign_in_form_and_submit
    end

    def fill_in_sign_in_form_and_submit
      fill_in 'name', with: user.name
      uncheck 'Admin' unless user.admin?
      click_button 'Sign in'
    end

    def signed_in?
      logged_in?
    end
  end
end
