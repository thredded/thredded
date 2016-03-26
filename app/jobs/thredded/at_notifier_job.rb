module Thredded
  class AtNotifierJob
    include Q::Methods

    queue(:send_at_notifications) do |post_type, post_id|
      ActiveRecord::Base.connection_pool.with_connection do
        NotifyMentionedUsers.new(post_type.to_s.constantize.find(post_id)).run
      end
    end
  end
end
