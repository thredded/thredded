# frozen_string_literal: true

require 'support/features/page_object/base'

module PageObject
  class Profile < Base
    def has_send_private_message_link?
      has_css? 'a', text: I18n.t('thredded.users.send_private_message')
    end

    def has_post_with_content?(content)
      has_css? '.thredded--post--content', text: content
    end
  end
end
