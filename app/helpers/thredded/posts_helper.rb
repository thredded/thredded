module Thredded
  module PostsHelper
    def link_to_edit_post(_, messageboard, topic, post)
      edit_messageboard_topic_post_path(messageboard.name, topic, post)
    end
  end
end
