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
      @targeted_users ||= @post.postable.followers.reject { |u| u == @post.user }
      exclude_those_opting_out_of_followed_activity_notifications @targeted_users
    end

    private

    def exclude_those_opting_out_of_followed_activity_notifications(members)
      members.select do |member|
        member.thredded_user_preference.followed_topic_emails &&
          member.thredded_user_messageboard_preferences.in(@post.messageboard).followed_topic_emails
      end
    end
  end
end
