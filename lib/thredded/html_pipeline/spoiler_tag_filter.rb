# frozen_string_literal: true

module Thredded
  module HtmlPipeline
    module SpoilerTagFilter
      PLACEHOLDER_START_CLASS = 'thredded-spoiler-placeholder-start-24uob7bajv5'
      PLACEHOLDER_END_CLASS = 'thredded-spoiler-placeholder-end-24uob7bajv5'
      PLACEHOLDER_START_BLOCK = "<p class='#{PLACEHOLDER_START_CLASS}' title='%s'></p>"
      PLACEHOLDER_END_BLOCK = "<p class='#{PLACEHOLDER_END_CLASS}' title='%s'></p>"
      PLACEHOLDER_START_SPAN = "<i class='#{PLACEHOLDER_START_CLASS}' title='%s'></i>"
      PLACEHOLDER_END_SPAN = "<i class='#{PLACEHOLDER_END_CLASS}' title='%s'></i>"

      class << self
        # @return [[[String, String]]] Pairs of opening and closing spoiler tags.
        attr_reader :spoiler_tags

        # @api private
        attr_reader :spoiler_tags_replacements

        # @api private
        attr_reader :spoiler_tags_inverse_replacements

        # @param [[[String, String]]] spoiler_tags
        def spoiler_tags=(spoiler_tags)
          @spoiler_tags = spoiler_tags.freeze
          @spoiler_tags_replacements = spoiler_tags.flat_map.with_index do |(open, close), i|
            [[/((?:\A|\r?\n|>)[ ]*)#{Regexp.escape(open)}(?=[ \t]*\r?(?:\n|\z))/, "\\1#{PLACEHOLDER_START_BLOCK % i}"],
             [/((?:\A|\r?\n|>)[ ]*)#{Regexp.escape(close)}(?=[ \t]*\r?(?:\n|\z))/, "\\1#{PLACEHOLDER_END_BLOCK % i}"],
             [open, PLACEHOLDER_START_SPAN % i],
             [close, PLACEHOLDER_END_SPAN % i]]
          end
          @spoiler_tags_inverse_replacements = spoiler_tags.flat_map.with_index do |(open, close), i|
            [[PLACEHOLDER_START_BLOCK % i, open],
             [PLACEHOLDER_END_BLOCK % i, close],
             [PLACEHOLDER_START_SPAN % i, open],
             [PLACEHOLDER_END_SPAN % i, close]]
          end
        end
      end

      self.spoiler_tags = [
        %w[<spoiler> </spoiler>],
      ].freeze

      class BeforeMarkup < ::HTML::Pipeline::Filter
        def call
          @html = +html # Unfreeze
          SpoilerTagFilter.spoiler_tags_replacements.each do |(pattern, replacement)|
            html.gsub! pattern, replacement
          end
          html
        end
      end

      class AfterMarkup < ::HTML::Pipeline::Filter
        include ::Thredded::HtmlPipeline::Utils

        SPOILER_START = [PLACEHOLDER_START_BLOCK, PLACEHOLDER_START_SPAN].freeze
        SPOILER_END = [PLACEHOLDER_END_BLOCK, PLACEHOLDER_END_SPAN].freeze

        def call
          doc.css(".#{PLACEHOLDER_START_CLASS}").each do |placeholder_start|
            process(placeholder_start)
          end
          doc.search('.//text()').each do |node|
            content = +node.content # Unfreeze
            SpoilerTagFilter.spoiler_tags_inverse_replacements.each do |(pattern, replacement)|
              content.gsub! pattern, replacement
            end
            node.content = content
          end
          doc
        end

        protected

        # @param [Nokogiri::XML::Document] document
        # @param [Array<Nokogiri::XML::Node>] children
        def build_spoiler_tag(document, children)
          document.create_element(
            'div',
            class: 'thredded--post--content--spoiler',
            tabindex: 0,
            role: 'figure',
            'aria-expanded' => 'false',
          ) << document.create_element(
            'div',
            I18n.t('thredded.posts.spoiler_summary'),
            class: 'thredded--post--content--spoiler--summary',
            'aria-hidden' => 'false',
          ) << document.create_element(
            'div',
            class: 'thredded--post--content--spoiler--contents',
            'aria-hidden' => 'true',
          ) { |contents_tag| children.each { |child| contents_tag.add_child child } }
        end

        private

        def process(placeholder_start)
          placeholder_end, children = find_placeholder_end(placeholder_start)
          placeholder_start.remove
          return if !placeholder_end || children.empty?
          spoiler_tag = placeholder_end.replace(build_spoiler_tag(doc.document, children))
          extract_block_from_paragraph! spoiler_tag
          spoiler_tag
        end

        def find_placeholder_end(sibling)
          children = []
          placeholder_end = nil
          loop do
            sibling = sibling.next_sibling
            break if sibling.nil?
            if sibling[:class] == PLACEHOLDER_START_CLASS
              sibling = process(sibling) || sibling
            elsif sibling[:class] == PLACEHOLDER_END_CLASS
              placeholder_end = sibling
              break
            end
            children << sibling
          end
          [placeholder_end, children]
        end
      end
    end
  end
end
