# frozen_string_literal: true

module Thredded
  module HtmlPipeline
    # Wraps iframes with a <div class="thredded--embed-16-by-9"/>
    class WrapIframesFilter < ::HTML::Pipeline::Filter
      def call
        doc.css('iframe').wrap('<div class="thredded--embed-16-by-9"/>')
        doc
      end
    end
  end
end
