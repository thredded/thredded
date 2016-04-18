# frozen_string_literal: true
require 'support/features/page_object/base'

module PageObject
  class Navigation < Base
    def has_unread_private_topics?
      all('.thredded--user-navigation--private-topics--unread').any?
    end
  end
end
