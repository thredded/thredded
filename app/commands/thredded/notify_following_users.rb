# frozen_string_literal: true
module Thredded
  class NotifyFollowingUsers
    def initialize(post)
      @post = post
    end

    def run
      return unless targetted_users.present?
      PostMailer.post_notification(@post.id, targetted_users.map(&:email)).deliver_now
      MembersMarkedNotified.new(@post, targetted_users).run
    end

    def targetted_users
      @targetted_users ||= @post.postable.following_users.reject { |u| u == @post.user }
    end
  end
end
