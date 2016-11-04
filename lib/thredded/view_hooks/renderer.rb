# frozen_string_literal: true
module Thredded
  module ViewHooks
    class Renderer
      # @param config [Thredded::ViewHooks::Config]
      def initialize(view_context, config)
        @view_context = view_context
        @config = config
      end

      # @return [String]
      def render(&original_content)
        @view_context.safe_join [
          *@config.before,
          *(@config.replace.presence || [original_content]),
          *@config.after,
        ].map { |proc| @view_context.capture(&proc) },
                                ''
      end
    end
  end
end
