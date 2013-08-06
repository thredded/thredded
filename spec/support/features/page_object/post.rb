require 'support/features/page_object/base'

module PageObject
  class Post < Base
    attr_accessor :post

    def initialize(post)
      @post = post
    end

    def visit_post_edit
      visit edit_messageboard_topic_post_path(
        post.messageboard,
        post.topic,
        post
      )
    end

    def change_content_to(content)
      fill_in 'Content', with: content
      click_button 'Update Post'
    end

    def editable?
      has_css?('textarea#post_content')
    end

    def has_bbcode_as_the_filter?
      find('#post_filter').value == 'bbcode'
    end

    def has_markdown_as_the_filter?
      find('#post_filter').value == 'markdown'
    end
  end
end
