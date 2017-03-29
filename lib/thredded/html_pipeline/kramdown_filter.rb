# frozen_string_literal: true
require 'kramdown'
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
        if @text.frozen?
          @text = @text.delete("\r")
        else
          @text.delete! "\r"
        end
      end

      # Convert Markdown to HTML using the best available implementation
      # and convert into a DocumentFragment.
      def call
        result = Kramdown::Document.new(@text, self.class.options.merge(context[:kramdown_options] || {})).to_html
        result.rstrip!
        result
      end
    end
  end
end
