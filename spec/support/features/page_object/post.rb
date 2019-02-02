# frozen_string_literal: true

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
      has_css? '.thredded--post--user', text: name
    end

    def has_content?(content)
      has_css? '.content p', text: content
    end

    def submit_new_content(content)
      fill_in I18n.t('thredded.posts.form.content_label'), with: content
      click_on I18n.t('thredded.posts.form.update_btn')
    end

    def start_quote
      open_post_actions
      within css_selector do
        click_on I18n.t('thredded.posts.quote_btn')
      end
    end

    def open_post_actions
      within css_selector do
        toggle = find('.thredded--post--dropdown')
        if Capybara.current_driver == :rack_test
          # hover is not supported with non-JS drivers
          toggle.click
        else
          # Using click here would be a race condition, because
          # in most JS drivers `click` is performed by moving
          # the mouse towards an element, then clicking.
          # The click could then be performed on a dropdown action.
          toggle.hover
          sleep(0.2) # wait a bit for animation
        end
      end
    end

    def css_selector
      "article#post_#{post.id}"
    end

    def listed?
      has_css? css_selector
    end

    def deletable?
      within css_selector do
        has_button? I18n.t('thredded.posts.delete')
      end
    end

    def delete
      within css_selector do
        click_button I18n.t('thredded.posts.delete')
      end
    end

    def mark_unread_from_here
      within css_selector do
        click_button I18n.t('thredded.topics.mark_as_unread')
      end
    end
  end
end
