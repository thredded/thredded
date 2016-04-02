module Thredded
  class NotifyPrivateTopicUsersJob < ::ActiveJob::Base
    queue_as :default

    def perform(private_topic_id)
      private_topic = Thredded::PrivateTopic.find(private_topic_id)

      NotifyPrivateTopicUsers.new(private_topic).run
    end
  end
end
