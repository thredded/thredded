# frozen_string_literal: true
require 'thredded/email_transformer/base'
module Thredded
  module EmailTransformer
    # Replaces YouTube iframes with links.
    class YoutubeOnebox < Base
      def call
        doc.css('.thredded--embed-16-by-9').each do |embed|
          url = embed.at('iframe')['src'].to_s
          next unless url.start_with?('https://www.youtube.com')
          video_id = %r{/embed/(.+?)(\?|$)}.match(url)[1]
          embed.swap paragraph(anchor("https://youtu.be/#{video_id}"))
        end
      end
    end
  end
end
