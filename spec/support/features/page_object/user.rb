module PageObject
  class User
    include Capybara::DSL
    include PageObject::Authentication
    include Rails.application.routes.url_helpers
    include FactoryGirl::Syntax::Methods

    attr_accessor :user

    def initialize(options={ name: 'user', email: 'user@example.com' })
      @user = create(:user, options)
    end

    def log_in
      visit new_session_path
      save_and_open_page
      fill_in 'name', with: user.name
      click_button 'Sign in'
    end

    def load_page
      visit user_path(@user)
    end

    def displaying_the_profile?
      has_content?(@user.name)
    end

    def has_redirected_with_error?
      has_content?("No user exists named #{@user.name}")
    end
  end
end
