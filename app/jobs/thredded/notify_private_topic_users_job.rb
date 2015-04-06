module Thredded
  class NotifyPrivateTopicUsersJob
    include Q::Methods

    queue(:send_notifications) do |private_topic_id|
      ActiveRecord::Base.connection_pool.with_connection do
        private_topic = PrivateTopic.find(private_topic_id)
        NotifyPrivateTopicUsers.new(private_topic).run if private_topic
      end
    end
  end
end
