module Thredded
  module PostsHelper
    def link_to_edit_post(site, messageboard, topic, post)
      path = edit_messageboard_topic_post_path(messageboard.name, topic, post)
    end
  end
end
