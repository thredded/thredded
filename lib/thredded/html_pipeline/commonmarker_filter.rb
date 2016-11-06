# frozen_string_literal: true
require 'commonmarker'
module Thredded
  module HtmlPipeline
    class CommonMarkerFilter < ::HTML::Pipeline::Filter

      class << self
        attr_accessor :parse_options
        attr_accessor :render_options
        attr_accessor :doc_processors
      end
      self.parse_options = %i(default)
      self.render_options = %i(default hardbreaks)
      self.doc_processors = []

      def call
        doc = CommonMarker.render_doc(html, self.class.parse_options)
        self.class.doc_processors.each { |proc| proc.call(doc) }
        result = doc.to_html(self.class.render_options)
        result.rstrip!
        result
      end
    end
  end
end
