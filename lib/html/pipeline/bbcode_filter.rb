require 'bbcoder'

module HTML
  class Pipeline
    class BbcodeFilter < TextFilter
      def initialize(text, context = {}, result = nil)
        super text, context, result
        @context = context
        @text = @text.gsub "\r", ''
      end

      def call
        html = BBCoder.new(@text).to_html.gsub(/\n|\r\n/, '<br />')
        html.rstrip!
        "<p>#{html}</p>"
      end
    end
  end
end
