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
      visit new_session_path
      fill_in 'name', with: user.to_s
      click_button 'Sign in'
    end

    def load_page
      visit Thredded.user_path(@user)
    end

    def displaying_the_profile?
      has_content?(@user.to_s)
    end

    def has_redirected_with_error?
      has_content?("No user exists named #{@user}")
    end
  end
end
