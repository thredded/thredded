module Thredded
  class AtNotifierJob
    include Q::Methods

    queue(:send_at_notifications) do |post_id|
      post = Post.find(post_id)

      NotifyMentionedUsers.new(post).run
    end
  end
end
