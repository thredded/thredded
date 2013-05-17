require 'redcarpet'

module Thredded
  module Filter
    module Markdown
      def self.included(base)
        base.class_eval do
          Thredded::Post::Filters << :markdown
        end
      end

      def filtered_content
        if filter.to_sym == :markdown
          renderer = Redcarpet::Render::HTML.new(hard_wrap: true, filter_html: true)
          markdown = Redcarpet::Markdown.new(renderer, autolink: true,
            space_after_headers: true, no_intraemphasis: true,
            fenced_code: true, gh_blockcode: true)
          @filtered_content = markdown.render(super).html_safe
        else
          super
        end
      end
    end
  end
end
