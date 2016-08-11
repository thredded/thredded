# frozen_string_literal: true
require 'support/features/page_object/base'

module PageObject
  class Topic < Base
    def initialize(topic)
      @topic = topic
      @messageboard = topic.messageboard
    end

    def first_post
      @first_post ||= PageObject::Post.new(@topic.posts.first)
    end

    def last_post
      @last_post ||= PageObject::Post.new(@topic.posts.last)
    end

    def visit_topic
      visit messageboard_topic_path(@messageboard, @topic)
    end

    def visit_topic_edit
      visit edit_messageboard_topic_path(@messageboard, @topic)
    end

    def editable?
      has_css? "form#edit_topic_#{@topic.id}"
    end

    def deletable?
      has_button? I18n.t('thredded.topics.delete_topic')
    end

    def listed?
      all('a', text: @topic.title).any?
    end

    def change_title_to(title)
      fill_in I18n.t('thredded.topics.form.title_label'), with: title
    end

    def make_locked
      check 'Locked'
    end

    def submit
      click_button I18n.t('thredded.topics.form.update_btn')
    end

    def delete
      click_button I18n.t('thredded.topics.delete_topic')
    end

    def locked?
      has_css?('.thredded--topic.thredded--topic-locked')
    end

    def has_redirected_after_delete?
      has_content?('Topic deleted')
    end
  end
end
