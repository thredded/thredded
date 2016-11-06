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
        remove_url_link_contents! html
        html.rstrip!
        html
      end

      # <a href="http://example.com">http://example.com</a> =>
      # <a href="http://example.com">example.com</a>
      def remove_url_link_contents!(html)
        # The doc is not fully HTML yet (it will still be parsed with markdown),
        # so we can't use Nokogiri to process it here.
        html.gsub!(%r{(<a href="[^"]*"[^>]*>)https?://(.*?</a>)}m, '\1\2')
      end
    end
  end
end
