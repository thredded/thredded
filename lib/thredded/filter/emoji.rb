require 'rails_emoji'

module Thredded
  module Filter
    module Emoji
      def filtered_content
        @filtered_content = RailsEmoji.render(super, size: 26).html_safe
      end
    end
  end
end
