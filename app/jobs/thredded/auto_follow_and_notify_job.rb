# frozen_string_literal: true
module Thredded
  class AutoFollowAndNotifyJob < ::ActiveJob::Base
    queue_as :default

    def perform(post_id)
      post = Post.find(post_id)

      AutofollowMentionedUsers.new(post).run
      NotifyFollowingUsers.new(post).run
    end
  end
end
