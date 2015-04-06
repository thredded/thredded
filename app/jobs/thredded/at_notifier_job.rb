module Thredded
  class AtNotifierJob
    include Q::Methods

    queue(:send_at_notifications) do |post_id|
      ActiveRecord::Base.connection_pool.with_connection do
        post = Post.find(post_id)
        NotifyMentionedUsers.new(post).run if post
      end
    end
  end
end
