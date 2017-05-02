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

    def first_post
      PageObject::Post.new(@posts.first)
    end

    def post_form
      PageObject::PostForm.new
    end

    def quote_page_for_post(post)
      messageboard_topic_path(
        topic.messageboard.slug,
        topic.slug,
        post: {
          quote_post_id: post.id
        }
      )
    end

    def quote_page_for_first_post
      quote_page_for_post(@posts.first)
    end

    private

    attr_reader :messageboard, :topic
  end
end
