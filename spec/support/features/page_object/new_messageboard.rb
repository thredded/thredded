module PageObject
  class NewMessageboard
    include Capybara::DSL
    include Thredded::Engine.routes.url_helpers

    def initialize
      visit root_path
    end

    def submit_form
      fill_in 'messageboard_name', with: 'Chat'
      fill_in 'messageboard_description', with: 'Talk about stuff'
      click_button 'Create New Messageboard'
    end

    def done?
      has_css? '#messageboards h2 a', text: 'Chat'
    end

    def has_a_sign_in_error_message?
      has_content? 'You are not signed in. Sign in or create an account before creating your messageboard.'
    end

    def has_a_new_messageboard_link?
      has_css? 'a.new_messageboard'
    end

    def showing_the_form?
      has_css? 'form #setup-container'
    end

    def on_the_messageboard_list?
      has_css? 'body#thredded_messageboards_index'
    end

    def visit_messageboard_list
      visit messageboards_path
    end

    def visit_new_messageboard_form
      visit new_messageboard_path
    end

    def click_new_messageboard
      find('a.new_messageboard').click
    end
  end
end
