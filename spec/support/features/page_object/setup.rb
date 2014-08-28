module PageObject
  class Setup
    include Capybara::DSL
    include Thredded::Engine.routes.url_helpers

    def initialize
      visit root_path
    end

    def submit_form
      fill_in 'messageboard_name', with: 'Chat'
      fill_in 'messageboard_description', with: 'Talk about stuff'
      click_button 'Continue'
    end

    def done?
      has_css? '#messageboards h2 a', text: 'Chat'
    end

    def has_a_sign_in_error_message?
      has_content? 'You are not signed in. Sign in or create an account before creating your messageboard.'
    end
  end
end
