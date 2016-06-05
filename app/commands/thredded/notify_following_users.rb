# frozen_string_literal: true
module Thredded
  class NotifyFollowingUsers
    def initialize(post)
      @post = post
    end

    def run
      return if targeted_users.empty?
      PostMailer.post_notification(@post.id, targeted_users.map(&:email)).deliver_now
      MembersMarkedNotified.new(@post, targeted_users).run
    end

    def targeted_users
      @targeted_users ||= @post.postable.following_users.reject { |u| u == @post.user }
    end
  end
end
