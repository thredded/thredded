# frozen_string_literal: true

module Thredded
  module HtmlPipeline
    module Utils
      private

      # If the given block element is contained in a paragraph, splits the paragraph and removes unnecessary whitespace.
      # @param [Nokogiri::HTML::Node] element the block element that may be inside a paragraph.
      def extract_block_from_paragraph!(element)
        p = element.parent
        return unless node_name?(p, 'p')
        children_after = p.children[p.children.index(element) + 1..-1]
        remove_leading_blanks! children_after
        # Move the element out of and after the paragraph
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
