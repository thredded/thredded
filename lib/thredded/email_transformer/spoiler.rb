# frozen_string_literal: true

require 'thredded/email_transformer/base'
module Thredded
  module EmailTransformer
    # Changes the spoiler tags to work in emails.
    class Spoiler < Base
      def call
        doc.css('.thredded--post--content--spoiler--summary').each do |node|
          node.content = I18n.t('thredded.posts.spoiler_summary_for_email')
        end
        doc.css('.thredded--post--content--spoiler--contents img').each do |img|
          text = "#{img['src']} #{" (#{img['alt']})" if img['alt'].present?}"
          img.swap(
            if img.parent.name == 'a' && img.parent.children.size == 1
              doc.document.create_text_node(text)
            else
              doc.document.create_element('a', text, href: img['src'], target: '_blank')
            end
          )
        end
      end
    end
  end
end
