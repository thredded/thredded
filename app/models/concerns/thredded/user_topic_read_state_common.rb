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

    module ClassMethods
      # @param user_id [Integer]
      # @param topic_id [Integer]
      # @param post [Thredded::PostCommon]
      def touch!(user_id, topic_id, post)
        # TODO: Switch to upsert once Travis supports PostgreSQL 9.5.
        # Travis issue: https://github.com/travis-ci/travis-ci/issues/4264
        # Upsert gem: https://github.com/seamusabshere/upsert
        state = find_or_initialize_by(user_id: user_id, postable_id: topic_id)
        return unless !state.read_at? || state.read_at < post.created_at
        state.update!(read_at: post.created_at)
      end

      def read_on_first_post!(user, topic)
        create!(user: user, postable: topic, read_at: Time.zone.now)
      end

      # Adds `first_unread_post_page` and `last_read_post_page` columns onto the scope.
      # Skips the records that have no read posts.
      def with_page_info( # rubocop:disable Metrics/MethodLength
        posts_per_page: topic_class.default_per_page, posts_scope: post_class.all
      )
        states = arel_table
        self_relation = is_a?(ActiveRecord::Relation) ? self : all
        if self_relation == unscoped
          states_select_manager = states
        else
          # Using the relation here is redundant but massively improves performance.
          states_select_manager = Thredded::ArelCompat.new_arel_select_manager(
            Arel::Nodes::TableAlias.new(Thredded::ArelCompat.relation_to_arel(self_relation), table_name)
          )
        end
        read = if posts_scope == post_class.unscoped
                 post_class.arel_table
               else
                 posts_subquery = Thredded::ArelCompat.relation_to_arel(posts_scope)
                 Arel::Nodes::TableAlias.new(posts_subquery, 'read_posts')
               end
        unread_topics = topic_class.arel_table
        page_info =
          states_select_manager
            .project(
              states[:id],
              Arel::Nodes::Case.new(unread_topics[:id].not_eq(nil))
                .when(Thredded::ArelCompat.true_value(self)).then(
                  Arel::Nodes::Addition.new(
                    Thredded::ArelCompat.integer_division(self, read[:id].count, posts_per_page), 1
                  )
                ).else(nil)
                .as('first_unread_post_page'),
              Arel::Nodes::Addition.new(
                Thredded::ArelCompat.integer_division(self, read[:id].count, posts_per_page),
                Arel::Nodes::Case.new(Arel::Nodes::InfixOperation.new(:%, read[:id].count, posts_per_page))
                  .when(0).then(0).else(1)
              ).as('last_read_post_page')
            )
            .join(read)
            .on(read[:postable_id].eq(states[:postable_id]).and(read[:created_at].lteq(states[:read_at])))
            .outer_join(unread_topics)
            .on(states[:postable_id].eq(unread_topics[:id]).and(unread_topics[:last_post_at].gt(states[:read_at])))
            .group(states[:id], unread_topics[:id])
            .as('id_and_page_info')

        # We use a subquery because selected fields must appear in the GROUP BY or be used in an aggregate function.
        select(states[Arel.star], page_info[:first_unread_post_page], page_info[:last_read_post_page])
          .joins(states.join(page_info).on(states[:id].eq(page_info[:id])).join_sources)
      end

      def topic_class
        reflect_on_association(:postable).klass
      end

      delegate :post_class, to: :topic_class
    end
  end
end
