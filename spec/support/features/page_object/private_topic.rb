# frozen_string_literal: true
require 'support/features/page_object/base'

module PageObject
  class PrivateTopic < Base
    def initialize(private_topic)
      @private_topic = private_topic
    end

    def visit_topic_edit
      visit edit_private_topic_path(@private_topic)
    end

    def editable?
      has_css? "form#edit_private_topic_#{@private_topic.id}"
    end

    def change_title_to(new_title)
      fill_in I18n.t('thredded.private_topics.form.title_label'), with: new_title
    end

    def submit
      click_button I18n.t('thredded.private_topics.form.update_btn')
    end

    def mark_unread_from_here
      within('.thredded--post--dropdown') do
        click_button('Mark unread from here')
      end
    end
  end
end
