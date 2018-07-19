# frozen_string_literal: true

module Thredded
  class AutoFollowAndNotifyJob < ::ActiveJob::Base
    queue_as :default

    def perform(post_id)
      post = Thredded::Post.find_by(id: post_id)
      return if post.nil? || post.postable.nil?

      Thredded::AutofollowUsers.new(post).run
      Thredded::NotifyFollowingUsers.new(post).run
    end
  end
end
