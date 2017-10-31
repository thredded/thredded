# frozen_string_literal: true

module PageObject
  class NewMessageboardGroup
    include Capybara::DSL
    include Thredded::Engine.routes.url_helpers

    def initialize
      visit root_path
    end

    def visit_new_messageboard_group_form
      visit new_messageboard_group_path
    end

    def submit_form
      fill_in 'messageboard_group_name', with: group_name
      click_create
    end

    def submit_form_with_duplicate_group_name
      create_messageboard_group
      submit_form
    end

    def click_create
      click_button I18n.t('thredded.messageboard_group.create')
    end

    def created?
      has_content? I18n.t('thredded.messageboard_group.saved', name: group_name)
    end

    def has_duplicate_messageboard_group_error?
      has_content? 'Name has already been taken'
    end

    def create_messageboard_group
      FactoryBot.create(:messageboard_group, name: group_name)
    end

    def group_name
      'Group'
    end
  end
end
