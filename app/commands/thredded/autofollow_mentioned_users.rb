# frozen_string_literal: true
module Thredded
  class AutofollowMentionedUsers
    def initialize(post)
      @post = post
    end

    def run
      members = autofollows
      return unless members.present?
    end

    def autofollows
      user_names = Thredded::AtNotificationExtractor.new(post.content).run
      members = post.readers_from_user_names(user_names).to_a

      members.delete post.user
      members = exclude_those_opting_out_of_at_notifications(members)

      members.each do |user|
        Thredded::UserTopicFollow.create_unique(user.id, @post.postable_id, Thredded::UserTopicFollow::REASON_MENTIONED)
      end
    end

    private

    attr_reader :post

    def exclude_those_opting_out_of_at_notifications(members)
      members.select do |member|
        member.thredded_user_preference.notify_on_mention? && member.thredded_user_messageboard_preferences.in(post
            .messageboard).notify_on_mention?
      end
    end
  end
end
