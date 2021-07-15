# frozen_string_literal: true

module Thredded
  module UserTopicReadStateCommon
    extend ActiveSupport::Concern
    included do
      extend ClassMethods
      validates :user_id, uniqueness: { scope: :postable_id }
      attribute :first_unread_post_page, ActiveRecord::Type::Integer.new
      attribute :last_read_post_page, ActiveRecord::Type::Integer.new
    end

    # @return [Boolean]
    def read?
      postable.last_post_at <= read_at
    end

    # @param post [Post or PrivatePost]
    # @return [Boolean]
    def post_read?(post)
      post.created_at <= read_at
    end

    # @return [Number]
    def posts_count
      read_posts_count + unread_posts_count
    end

    def calculate_post_counts
      relation = self.class.visible_posts_scope(user).where(postable_id: postable_id)
      unread_posts_count, read_posts_count =
        relation.pluck(*self.class.post_counts_arel(read_at))[0]
      { unread_posts_count: unread_posts_count || 0, read_posts_count: read_posts_count || 0 }
    end

    module ClassMethods
      delegate :post_class, to: :topic_class

      # Adds `first_unread_post_page` and `last_read_post_page` columns onto the scope.
      # Skips the records that have no read posts.
      def with_page_info(posts_per_page: post_class.default_per_page)
        states = arel_table
        selects = []
        selects << states[Arel.star] if !is_a?(ActiveRecord::Relation) || select_values.empty?
        selects += [
          Arel::Nodes::Case.new(states[:unread_posts_count].not_eq(0))
            .when(true).then(
              Arel::Nodes::Addition.new(
                Thredded::ArelCompat.integer_division(self, states[:read_posts_count], posts_per_page), 1
              )
            ).else(nil).as('first_unread_post_page'),
          Arel::Nodes::Addition.new(
            Thredded::ArelCompat.integer_division(self, states[:read_posts_count], posts_per_page),
            Arel::Nodes::Case.new(Arel::Nodes::InfixOperation.new(:%, states[:read_posts_count], posts_per_page))
              .when(0).then(0).else(1)
          ).as('last_read_post_page')
        ]
        select(selects)
      end

      # Calculates and saves the `unread_posts_count` and `read_posts_count` columns.
      def update_post_counts!
        id_counts = calculate_post_counts_for_users(Thredded.user_class.where(id: distinct.select(:user_id)))
        transaction do
          id_counts.each do |(id, unread_posts_count, read_posts_count)|
            where(id: id).update_all(unread_posts_count: unread_posts_count, read_posts_count: read_posts_count)
          end
        end
      end

      # @param [DateTime, Arel::Node] read_at
      # @param [Arel::Table] posts
      # @return [[Arel::Node, Arel::Node]] `unread_posts_count` and `read_posts_count` nodes.
      def post_counts_arel(read_at, posts: post_class.arel_table)
        [
          Arel::Nodes::Sum.new(
            [Arel::Nodes::Case.new(posts[:created_at].gt(read_at))
               .when(true).then(1).else(0)]
          ).as('unread_posts_count'),
          Arel::Nodes::Sum.new(
            [Arel::Nodes::Case.new(posts[:created_at].gt(read_at))
               .when(true).then(0).else(1)]
          ).as('read_posts_count')
        ]
      end

      # @return [Array<[id, unread_posts_count, read_posts_count]>]
      def calculate_post_counts
        states = arel_table
        posts = post_class.arel_table
        relation = joins(states.join(posts).on(states[:postable_id].eq(posts[:postable_id])).join_sources)
          .group(states[:id])
        relation.pluck(states[:id], *post_counts_arel(states[:read_at], posts: posts))
      end
    end
  end
end
