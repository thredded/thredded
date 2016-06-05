# frozen_string_literal: true
module Thredded
  class AutofollowMentionedUsers
    def initialize(post)
      @post = post
    end

    def run
      autofollowers.each do |user|
        Thredded::UserTopicFollow.create_unique(user.id, post.postable_id, :mentioned)
      end
    end

    def autofollowers
      user_names = Thredded::AtNotificationExtractor.new(post.content).run
      autofollowers = post.readers_from_user_names(user_names).to_a
      autofollowers.delete post.user
      exclude_those_opting_out_of_at_notifications(autofollowers)
    end

    private

    attr_reader :post

    def exclude_those_opting_out_of_at_notifications(members)
      members.select do |member|
        member.thredded_user_preference.notify_on_mention? &&
          member.thredded_user_messageboard_preferences.in(post.messageboard).notify_on_mention?
      end
    end
  end
end
