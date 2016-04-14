# frozen_string_literal: true
require 'support/features/page_object/base'

module PageObject
  class PrivateTopics < Base
    def initialize(title = 'this is private')
      @private_title = title
    end

    def visit_index
      visit private_topics_path(messageboard)
    end

    def view_private_topic
      click_on @private_title
    end

    def private_topics
      all('article.thredded--private-topic')
    end

    def read_private_topics
      all('.thredded--topic--read.thredded--private-topic')
    end

    def unread_private_topics
      all('.thredded--topic--unread.thredded--private-topic')
    end

    def create_private_topic
      user = create(:user, name: 'carl')
      visit new_private_topic_path
      fill_in 'Title', with: private_title
      find(:css, '#private_topic_user_ids').set(user.id)
      fill_in I18n.t('thredded.private_topics.form.content_label'), with: 'not for others'

      click_on I18n.t('thredded.private_topics.form.create_btn')
    end

    def update_all_private_topics
      Thredded::PrivateUser.update_all(read: false)
    end

    def visit_private_topic_list
      visit private_topics_path(messageboard)
    end

    def on_private_list?
      visit private_topics_path(messageboard)

      has_css? 'article h1 a', text: private_title
    end

    alias_method :private_topic, :private_topics
    alias_method :unread_private_topic, :unread_private_topics

    private

    attr_reader :messageboard, :private_title
  end
end
