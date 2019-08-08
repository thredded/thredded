# frozen_string_literal: true

require 'support/features/page_object/base'

module PageObject
  class MessageBoard < Base
    attr_accessor :messageboard

    def initialize(messageboard)
      @messageboard = messageboard
    end

    def listed?
      has_content? @messageboard.name
    end

    def deletable?
      has_button? 'Delete'
    end

    def delete
      click_button 'Delete'
    end

    def visit_messageboard_edit
      visit edit_messageboard_path(@messageboard)
    end

    def has_redirected_after_delete?
      has_content?('Messageboard deleted')
    end
  end
end
