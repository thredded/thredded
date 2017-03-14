# frozen_string_literal: true
require 'onebox'

module Thredded
  module HtmlPipeline
    class OneboxFilter < ::HTML::Pipeline::Filter
      SANITIZE_CONFIG = Sanitize::Config.merge(
        Sanitize::Config::ONEBOX,
        attributes: {
          'a' => Sanitize::Config::ONEBOX[:attributes]['a'] + %w(target),
        },
        add_attributes: {
          'iframe' => {
            'seamless' => 'seamless',
            'sandbox' => 'allow-same-origin allow-scripts allow-forms allow-popups allow-popups-to-escape-sandbox',
          }
        },
        transformers: (Sanitize::Config::ONEBOX[:transformers] || []) + [
          lambda do |env|
            next unless env[:node_name] == 'a'
            a_tag = env[:node]
            a_tag['href'] ||= '#'
            if a_tag['href'] =~ %r{^(?:[a-z]+:)?//}
              a_tag['target'] = '_blank'
              a_tag['rel']    = 'nofollow noopener'
            else
              a_tag.remove_attribute('target')
            end
          end
        ]
      )

      def call
        doc = self.doc.is_a?(String) ? Nokogiri::HTML.fragment(self.doc) : self.doc
        doc.css('a').each do |element|
          url = element['href'].to_s
          next unless url.present? && url == element.content
          onebox_html = Onebox.preview(url, self.class.onebox_options(url)).to_s.strip
          next if onebox_html.empty?
          fixup_paragraph! doc, element
          element.swap onebox_html
        end
        doc
      end

      def self.onebox_options(_url)
        cache = if Rails.env.development? || Rails.env.test?
                  # In development and test, caching is usually disabled.
                  # Regardless, always store the onebox in a file cache to enable offline development,
                  # persistence between test runs, and to improve performance.
                  @cache ||= Moneta.new(:File, dir: 'tmp/cache/onebox')
                else
                  Rails.cache
                end
        { cache: cache, sanitize_config: SANITIZE_CONFIG }
      end

      private

      def fixup_paragraph!(doc, element)
        # Can't have a div inside a paragraph, so split the paragraph
        p = element.parent
        return unless node_name?(p, 'p')
        children_after = p.children[p.children.index(element) + 1..-1]
        remove_leading_blanks! children_after
        # Move the onebox out of and after the paragraph
        p.add_next_sibling element
        # Move all the elements after the onebox to a new paragraph
        unless children_after.empty?
          new_p = Nokogiri::XML::Node.new 'p', doc
          element.add_next_sibling new_p
          children_after.each { |child| new_p.add_child child }
        end
        # The original paragraph might have been split just after a <br> or whitespace, remove them if so:
        remove_leading_blanks! p.children.reverse
        p.remove if p.children.empty?
      end

      # @param children [Nokogiri::XML::NodeSet]
      def remove_leading_blanks!(children)
        to_remove = children.take_while do |c|
          if node_name?(c, 'br') || c.text? && c.content.blank?
            c.remove
            true
          else
            c.content = c.content.lstrip
            false
          end
        end
        to_remove.each { |c| children.delete(c) }
      end

      def node_name?(node, node_name)
        node && node.node_name && node.node_name.casecmp(node_name).zero?
      end
    end
  end
end
