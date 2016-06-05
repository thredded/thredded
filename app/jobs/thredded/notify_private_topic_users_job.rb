# frozen_string_literal: true
module Thredded
  class NotifyPrivateTopicUsersJob < ::ActiveJob::Base
    queue_as :default

    def perform(private_post_id)
      private_post = Thredded::PrivatePost.find(private_post_id)
      NotifyPrivateTopicUsers.new(private_post).run
    end
  end
end
