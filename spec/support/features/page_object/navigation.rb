require 'support/features/page_object/base'

module PageObject
  class Navigation < Base
    def has_unread_private_topics?
      all('.thredded--topic-navigation--private .thredded--topic-navigation--unread').any?
    end
  end
end
