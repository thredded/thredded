# frozen_string_literal: true

module Thredded
  # A view model for a page of MessageboardGroupViews.
  class MessageboardGroupView
    delegate :name, :id, to: :@group, allow_nil: true
    attr_reader :group, :messageboards, :messageboard_ids

    # @param [ActiveRecord::Relation<Thredded::Messageboard>] messageboards_scope
    # @param [Thredded.user_class] user The user viewing the messageboards.
    # @param [Boolean] with_unread_topics_counts
    # @return [Array<MessageboardGroupView>]
    def self.grouped( # rubocop:disable Metrics/MethodLength,Metrics/CyclomaticComplexity
      messageboards_scope, user: Thredded::NullUser.new, with_unread_topics_counts: !user.thredded_anonymous?
    )
      scope = messageboards_scope.preload(last_topic: [:last_user])
        .eager_load(:group)
        .order(Arel.sql('COALESCE(thredded_messageboard_groups.position, 0) ASC, thredded_messageboard_groups.id ASC'))
        .ordered
      topics_scope = Thredded::TopicPolicy::Scope.new(user, Thredded::Topic.all).resolve
      if with_unread_topics_counts
        unread_topics_counts = messageboards_scope.unread_topics_counts(user: user, topics_scope: topics_scope)
        unread_followed_topics_counts = messageboards_scope.unread_topics_counts(
          user: user, topics_scope: topics_scope.followed_by(user)
        )
      end
      topic_counts = topics_scope.group(:messageboard_id).count
      posts_scope = Thredded::PostPolicy::Scope.new(user, Thredded::Post.all).resolve
      post_counts = posts_scope.group(:messageboard_id).count
      scope.group_by(&:group).map do |(group, messageboards)|
        MessageboardGroupView.new(group, messageboards.map do |messageboard|
          MessageboardView.new(
            messageboard,
            topics_count: topic_counts[messageboard.id] || 0,
            posts_count: post_counts[messageboard.id] || 0,
            unread_topics_count: with_unread_topics_counts && unread_topics_counts[messageboard.id] || 0,
            unread_followed_topics_count:
              with_unread_topics_counts && unread_followed_topics_counts[messageboard.id] || 0
          )
        end)
      end
    end

    # @param [Thredded::MessageboardGroup] group
    # @param [Array<Thredded::MessageboardView>] messageboards
    def initialize(group, messageboards)
      @group = group
      @messageboards = messageboards
      @messageboard_ids = messageboards.map { |messageboard| messageboard.messageboard.id }
    end
  end
end
