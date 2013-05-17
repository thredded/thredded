require 'thredded/at_users'

module Thredded
  module Filter
    module AtNotification
      def filtered_content
        @filtered_content = Thredded::AtUsers.render(super, messageboard).html_safe
      end
    end
  end
end
