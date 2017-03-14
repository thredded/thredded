# frozen_string_literal: true
require 'thredded/email_transformer/base'
module Thredded
  module EmailTransformer
    # Wraps oneboxes with tables, because only tables can have borders in most email clients.
    class Onebox < Base
      def call
        doc.css('aside.onebox').each do |onebox|
          table = Nokogiri::XML::Node.new('table', doc)
          table['class'] = 'onebox-wrapper-table'
          onebox.swap table
          table
            .add_child(Nokogiri::XML::Node.new('tr', doc))
            .add_child(Nokogiri::XML::Node.new('td', doc))
            .add_child(onebox)
        end
      end
    end
  end
end
