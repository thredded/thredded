# frozen_string_literal: true
module Thredded
  class NotifyFollowingUsers
    def initialize(post)
      @post = post
    end

    def run
      return if targeted_users.empty?
      Thredded.notifiers.each do |notifier|
        notifier.new.new_post(@post, targeted_users)
      end
    end

    def targeted_users
      @targeted_users ||= @post.postable.followers.reject { |u| u == @post.user }
    end
  end
end
