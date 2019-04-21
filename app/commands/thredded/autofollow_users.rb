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
    #
    #    COALESCE(
    #      `user_messageboard_preferences`.`auto_follow_topics`,
    #      `user_preferences`.`auto_follow_topics`,
    #      default for `user_preferences`.`auto_follow_topics`
    #    ) = true
    #
    # @return [Enumerable<Thredded.user_class>]
    def auto_followers
      u = Thredded.user_class.arel_table
      u_pkey = u[Thredded.user_class.primary_key]
      up = Thredded::UserPreference.arel_table
      ump = Thredded::UserMessageboardPreference.arel_table
      coalesce = [
        ump[:auto_follow_topics],
        up[:auto_follow_topics],
      ]
      coalesce << Arel::Nodes::Quoted.new(true) if Thredded::UserPreference.column_defaults['auto_follow_topics']
      Thredded.user_class
        .select(Thredded.user_class.primary_key)
        .joins(
          u.join(up, Arel::Nodes::OuterJoin)
            .on(up[:user_id].eq(u_pkey))
            .join(ump, Arel::Nodes::OuterJoin)
            .on(ump[:user_id].eq(u_pkey).and(ump[:messageboard_id].eq(post.messageboard_id)))
            .join_sources
        ).where(Arel::Nodes::NamedFunction.new('COALESCE', coalesce).eq(true))
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
