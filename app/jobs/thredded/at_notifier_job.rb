module Thredded
  class AtNotifierJob
    include Q::Methods

    queue(:send_at_notifications) do |post_id|
      post = Post.find(post_id)

      AtNotifier.new(post).notifications_for_at_users
    end
  end
end
