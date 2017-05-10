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
      def render(**args, &original_content)
        @view_context.safe_join [
          *@config.before,
          *(@config.replace.presence || [original_content]),
          *@config.after,
        ].map { |proc| render_proc(**args, &proc) }, ''
      end

      private

      def render_proc(**args, &proc)
        @view_context.capture do
          @view_context.instance_exec(**args, &proc)
        end
      end
    end
  end
end
