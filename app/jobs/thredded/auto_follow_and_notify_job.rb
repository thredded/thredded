# frozen_string_literal: true

module Thredded
  class AutoFollowAndNotifyJob < ::ActiveJob::Base
    queue_as :default

    def perform(post_id)
      post = Thredded::Post.find(post_id)

      Thredded::AutofollowUsers.new(post).run
      Thredded::NotifyFollowingUsers.new(post).run
    end
  end
end
