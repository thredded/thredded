require 'thredded/at_users'

module HTML
  class Pipeline
    class AtMentionFilter < Filter
      def initialize(text, context = nil, result = nil)
        super text, context, result
        @text = text.to_s.gsub "\r", ''
        @post = context[:post]
      end

      def call
        html = Thredded::AtUsers.render(@text, @post.messageboard)
        html.rstrip!
        html
      end
    end
  end
end
