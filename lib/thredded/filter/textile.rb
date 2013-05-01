module Thredded
  module Filter
    module Textile
      def self.included(base)
        base.class_eval do
          Thredded::Post::Filters << :textile
        end
      end

      def filtered_content
        if filter.to_sym == :textile
          @filtered_content = RedCloth.new(super).to_html.html_safe
        else
          @filtered_content = super
        end
      end
    end
  end
end
