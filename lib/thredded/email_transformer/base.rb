# frozen_string_literal: true

module Thredded
  module EmailTransformer
    # A helper module with common functions for constructing Nokogiri elements.
    module Helpers
      # Creates a `<p>` node with the given child
      def paragraph(child)
        Nokogiri::XML::Node.new('p', doc).tap do |p|
          p.add_child child
        end
      end

      # Creates an `<a>` node with the given attributes and content
      def anchor(href, target: '_blank', content: href)
        Nokogiri::XML::Node.new('a', doc).tap do |a|
          a['href'] = href
          a['target'] = target
          a.content = content
        end
      end
    end

    class Base
      include Helpers

      # @return [Nokogiri::HTML::Document]
      attr_reader :doc

      # @param doc [Nokogiri::HTML::Document]
      def initialize(doc)
        @doc = doc
      end

      def self.inherited(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # @param doc [Nokogiri::HTML::Document]
        def call(doc)
          new(doc).call
        end
      end
    end
  end
end
