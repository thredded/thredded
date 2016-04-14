# frozen_string_literal: true
require 'support/features/page_object/base'

module PageObject
  class Posts < Base
    attr_accessor :posts, :reply_content

    def initialize(posts)
      @posts = posts
      @messageboard = @posts.first.messageboard
      @topic = @posts.first.postable
    end

    def visit_posts
      visit messageboard_topic_path(messageboard, topic)
    end

    def submit_reply(content = 'I replied')
      self.reply_content = content
      fill_in 'Content', with: reply_content
      click_button 'Submit Reply'
    end

    def posts
      all('article.thredded--post')
    end

    def has_new_reply?
      has_content?(reply_content)
    end

    def has_a_bold?(content)
      has_css?('strong', text: content)
    end

    private

    attr_reader :messageboard, :topic
  end
end
