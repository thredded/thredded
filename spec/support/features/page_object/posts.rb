require 'support/features/page_object/base'

module PageObject
  class Posts < Base
    attr_accessor :posts, :reply_content

    def initialize(posts)
      @posts = posts
      @messageboard = @posts.first.messageboard
      @topic = @posts.first.topic
    end

    def visit_posts
      visit messageboard_topic_posts_path(messageboard, topic)
    end

    def use_bbcode
      select 'bbcode', from: 'post_filter'
    end

    def submit_reply(content='I replied')
      self.reply_content = content
      fill_in 'Content', with: reply_content
      click_button 'Submit reply'
    end

    def posts
      all('article.post')
    end

    def has_new_reply?
      has_content?(reply_content)
    end

    def has_a_bold?(content)
      has_css?('strong', text: content)
    end

    def has_markdown_as_default_filter?
      find('#post_filter').value == 'markdown'
    end

    def has_bbcode_as_default_filter?
      find('#post_filter').value == 'bbcode'
    end

    private

    attr_reader :messageboard, :topic
  end
end
