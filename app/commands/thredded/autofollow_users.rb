# frozen_string_literal: true
module Thredded
  class AutofollowUsers
    def initialize(post)
      @post = post
    end

    def run
      new_followers.each do |user, reason|
        Thredded::UserTopicFollow.create_unless_exists(user.id, post.postable_id, reason)
      end
    end

    # @return [Array<Thredded.user_class>]
    def mentioned_users
      @mentioned_users ||= Thredded::AtNotificationExtractor.new(post).run
    end

    # @return [Hash<Thredded.user_class, Symbol]>] a map of users that should get subscribed to their the follow reason.
    def new_followers
      result = {}
      auto_followers.each { |user| result[user] = :auto }
      exclude_follow_on_mention_opt_outs(mentioned_users).each { |user| result[user] = :mentioned }
      result.delete(post.user)
      result
    end

    private

    attr_reader :post

    # Returns the users that have:
    #   UserMessageboardPreference#auto_follow_topics? && UserPreference#auto_follow_topics?
    # If the `user_preference` for a given does not exist, its default value is used.
    # @return [Enumerable<Thredded.user_class>]
    def auto_followers
      user_board_prefs = post.messageboard.user_messageboard_preferences.each_with_object({}) do |ump, h|
        h[ump.user] = ump
      end
      User.includes(:thredded_user_preference).all.select do |user|
        (user_board_prefs[user] ||
            Thredded::UserMessageboardPreference.new(messageboard: post.messageboard, user: user)).auto_follow_topics?
      end
    end

    # @return [Enumerable<Thredded.user_class>]
    def exclude_follow_on_mention_opt_outs(users)
      users.select do |user|
        user.thredded_user_preference.follow_topics_on_mention? &&
          user.thredded_user_messageboard_preferences.in(post.messageboard).follow_topics_on_mention?
      end
    end
  end
end
