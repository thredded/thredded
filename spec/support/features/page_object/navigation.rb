# frozen_string_literal: true

require 'support/features/page_object/base'

module PageObject
  class Navigation < Base
    def has_unread_private_topics?
      all('.thredded--user-navigation--private-topics--unread').any?
    end

    def unread_followed_topics_count
      badge = find('.thredded--user-navigation--unread-topics--followed-count')
      return 0 unless badge
      badge.text.to_i
    end

    def click_unread
      click_link(text: /\A#{Regexp.escape I18n.t('thredded.nav.unread_topics')}(?: \d+)?\z/)
    end
  end
end
