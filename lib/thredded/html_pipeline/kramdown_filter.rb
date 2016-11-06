# frozen_string_literal: true
require 'kramdown'
require 'thredded/html_pipeline/autolink_filter'
module Thredded
  module HtmlPipeline
    class KramdownFilter < ::HTML::Pipeline::TextFilter
      class << self
        attr_accessor :options
      end

      # See http://kramdown.gettalong.org/options.html
      self.options = {
        input: 'GFM',
        gfm_quirks: 'paragraph_end',
        # Smart quotes conflict with @"at mentions". Disable smart quotes.
        smart_quotes: %w(apos apos quot quot),
        remove_block_html_tags: false,
        syntax_highlighter: nil
      }

      def initialize(text, context = nil, result = nil)
        super text, context, result
        @text.delete! "\r"
      end

      # Convert Markdown to HTML using the best available implementation
      # and convert into a DocumentFragment.
      def call
        result = Kramdown::Document.new(@text, self.class.options).to_html
        result.rstrip!
        auto_link result
      end

      private

      def auto_link(html)
        # Autolink is required because Kramdown does not autolink by default.
        # https://github.com/gettalong/kramdown/issues/306
        Thredded::HtmlPipeline::AutolinkFilter.call(html, @context)
      end
    end
  end
end
