module Thredded
  class NotifyPrivateTopicUsersJob
    include Q::Methods

    queue(:send_notifications) do |private_topic_id|
      private_topic = PrivateTopic.find(private_topic_id)
      NotifyPrivateTopicUsers.new(private_topic).run
    end
  end
end
