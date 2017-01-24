# frozen_string_literal: true
module Thredded
  class AutofollowUsers
    def initialize(post)
      @post = post
    end

    def run
      autofollowers.each do |user|
        reason = mentioned_users.include?(user) ? :mentioned : :auto
        Thredded::UserTopicFollow.create_unless_exists(user.id, post.postable_id, reason)
      end
    end

    def mentioned_users
      @mentioned_users ||= Thredded::AtNotificationExtractor.new(post).run
    end

    def autofollowers
      autofollowers = (include_auto_followers + mentioned_users).uniq
      autofollowers.delete(post.user)
      exclude_those_opting_out_of_at_notifications autofollowers
    end

    private

    attr_reader :post

    def include_auto_followers
      post.messageboard.user_messageboard_preferences.auto_followers.map(&:user)
    end

    def exclude_those_opting_out_of_at_notifications(members)
      members.select do |member|
        member.thredded_user_preference.follow_topics_on_mention? &&
          member.thredded_user_messageboard_preferences.in(post.messageboard).follow_topics_on_mention?
      end
    end
  end
end
