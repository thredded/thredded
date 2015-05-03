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
        post.postable,
        post
      )
    end

    def change_content_to(content)
      fill_in 'Content', with: content
      click_button 'Update Post'
    end

    def editable?
      has_css? 'form[id^="edit_post"]'
    end

    def authored_by?(name)
      has_css? '.post--user', text: name
    end

    def has_content?(content)
      has_css? '.content p', text: content
    end

    def submit_new_content(content)
      fill_in 'Content', with: content
      click_on 'Update Post'
    end
  end
end
