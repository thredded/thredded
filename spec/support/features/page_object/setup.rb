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
  end
end
