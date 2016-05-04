# frozen_string_literal: true
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
      click_button I18n.t('thredded.messageboard.create')
    end

    def done?
      has_css? '.thredded--messageboards header h2', text: 'Chat'
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
      has_css? '#thredded--container[data-thredded-page-id="thredded--messageboards-index"]'
    end

    def on_access_forbidden_page?
      has_css? '#thredded--container[data-thredded-page-id="thredded--error-forbidden"]'
    end

    def visit_messageboard_list
      visit messageboards_path
    end

    def visit_new_messageboard_form
      visit new_messageboard_path
    end

    def click_new_messageboard
      click_link I18n.t('thredded.messageboard.create')
    end
  end
end
