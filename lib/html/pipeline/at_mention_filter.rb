require 'thredded/at_users'

module HTML
  class Pipeline
    class AtMentionFilter < Filter
      def initialize(text, context = nil, result = nil)
        super text, context, result
        @text = text.to_s.gsub "\r", ''
        @post = context[:post]
        @view_context = context[:view_context]
      end

      def call
        html = Thredded::AtUsers.render(@text, @post.messageboard, @view_context)
        html.rstrip!
        html
      end
    end
  end
end
