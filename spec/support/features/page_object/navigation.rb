require 'support/features/page_object/base'

module PageObject
  class Navigation < Base
    def has_unread_private_topics?
      all('.unread.private_topic').any?
    end
  end
end
