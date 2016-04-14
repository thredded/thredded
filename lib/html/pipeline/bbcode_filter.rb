# frozen_string_literal: true
require 'bbcoder'

module HTML
  class Pipeline
    class BbcodeFilter < TextFilter
      def initialize(text, context = {}, result = nil)
        super text, context, result
      end

      def call
        html = BBCoder.new(@text).to_html
        html = remove_url_link_contents(html)
        html.delete('<br>')
        html.rstrip!
        html
      end

      def remove_url_link_contents(html)
        doc = Nokogiri::HTML::DocumentFragment.parse(html)
        doc.css('a').each do |link|
          link.content = link.content.gsub(%r{https?://}, '')
        end
        doc.to_html
      end
    end
  end
end
