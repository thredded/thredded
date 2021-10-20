# frozen_string_literal: true

module Thredded
  class Topic < ActiveRecord::Base # rubocop:disable Metrics/ClassLength
    include Thredded::TopicCommon
    include Thredded::ContentModerationState

    scope :for_messageboard, ->(messageboard) { where(messageboard_id: messageboard.id) }

    scope :stuck, -> { where(sticky: true) }
    scope :unstuck, -> { where(sticky: false) }

    # Using `search_query` instead of `search` to avoid conflict with Ransack.
    scope :search_query, ->(query) { ::Thredded::TopicsSearch.new(query, self).search }

    scope :order_sticky_first, -> { order(sticky: :desc) }
    scope :order_followed_first, ->(user) {
      user_follows = UserTopicFollow.arel_table
      joins(arel_table.join(user_follows, Arel::Nodes::OuterJoin)
              .on(user_follows[:topic_id].eq(arel_table[:id])
                  .and(user_follows[:user_id].eq(user.id))).join_sources)
        .order(Arel::Nodes::Ascending.new(user_follows[:id].eq(nil)))
    }

    scope :followed_by, ->(user) {
      joins(:user_follows)
        .where(thredded_user_topic_follows: { user_id: user.id })
    }
    scope :unread_followed_by, ->(user) { followed_by(user).unread(user) }

    extend FriendlyId
    friendly_id :slug_candidates,
                use: %i[history reserved],
                # Avoid route conflicts
                reserved_words: ::Thredded::FriendlyIdReservedWordsAndPagination.new(%w[topics unread])

    belongs_to :user,
               class_name: Thredded.user_class_name,
               inverse_of: :thredded_topics,
               optional: true

    belongs_to :messageboard,
               counter_cache: true,
               touch: true,
               inverse_of: :topics
    validates :messageboard_id, presence: true

    belongs_to :user_detail,
               primary_key:   :user_id,
               foreign_key:   :user_id,
               inverse_of:    :topics,
               counter_cache: :topics_count,
               optional: true

    has_many :posts,
             autosave: true,
             class_name:  'Thredded::Post',
             foreign_key: :postable_id,
             inverse_of:  :postable,
             dependent:   :destroy
    has_one :first_post, # rubocop:disable Rails/InverseOf
            -> { order_oldest_first },
            class_name: 'Thredded::Post',
            foreign_key: :postable_id
    has_one :last_post, # rubocop:disable Rails/InverseOf
            -> { order_newest_first },
            class_name: 'Thredded::Post',
            foreign_key: :postable_id

    has_many :topic_categories, inverse_of: :topic, dependent: :delete_all
    has_many :categories, through: :topic_categories
    has_many :user_read_states,
             class_name: 'Thredded::UserTopicReadState',
             foreign_key: :postable_id,
             inverse_of: :postable,
             dependent: :delete_all
    has_many :user_follows,
             class_name: 'Thredded::UserTopicFollow',
             inverse_of: :topic,
             dependent: :destroy
    has_many :followers,
             class_name: Thredded.user_class_name,
             source: :user,
             through: :user_follows

    delegate :name, to: :messageboard, prefix: true

    after_commit :update_messageboard_last_topic, on: :update, if: -> { previous_changes.include?('moderation_state') }
    after_commit :update_last_user_and_time_from_last_post!, if: -> { previous_changes.include?('moderation_state') }

    after_commit :handle_messageboard_change_after_commit,
                 on: :update,
                 if: -> { previous_changes.include?('messageboard_id') }

    # Finds the topic by its slug or ID, or raises Thredded::Errors::TopicNotFound.
    # @param slug_or_id [String]
    # @return [Thredded::Topic]
    # @raise [Thredded::Errors::TopicNotFound] if the topic with the given slug does not exist.
    def self.friendly_find!(slug_or_id)
      friendly.find(slug_or_id)
    rescue ActiveRecord::RecordNotFound
      raise Thredded::Errors::TopicNotFound
    end

    class << self
      private

      # @param user [Thredded.user_class]
      # @return [ByPostableLookup]
      def follows_by_topic_hash(user)
        Thredded::TopicCommon::CachingHash.from_relation(
          Thredded::UserTopicFollow.where(user_id: user.id, topic_id: current_scope.map(&:id))
        )
      end

      public

      def post_class
        Thredded::Post
      end

      # @param user [Thredded.user_class]
      # @return [Array<[TopicCommon, UserTopicReadStateCommon, UserTopicFollow]>]
      def with_read_and_follow_states(user)
        topics = current_scope.to_a
        if user.thredded_anonymous?
          post_counts = post_counts_for_user_and_topics(user, topics.map(&:id))
          topics.map do |topic|
            [topic, Thredded::NullUserTopicReadState.new(posts_count: post_counts[topic.id] || 0), nil]
          end
        else
          read_states_by_topic = read_states_by_postable_hash(user)
          post_counts = post_counts_for_user_and_topics(
            user, topics.reject { |topic| read_states_by_topic.key?(topic) }.map(&:id)
          )
          follows_by_topic = follows_by_topic_hash(user)
          current_scope.map do |topic|
            [
              topic,
              read_states_by_topic[topic] ||
                Thredded::NullUserTopicReadState.new(posts_count: post_counts[topic.id] || 0),
              follows_by_topic[topic]
            ]
          end
        end
      end
    end

    def public?
      true
    end

    # @return [Thredded::PostModerationRecord, nil]
    def last_moderation_record
      first_post.try(:last_moderation_record)
    end

    def update_last_user_and_time_from_last_post!
      return if destroyed?
      scope = posts.order_newest_first
      scope = scope.moderation_state_visible_to_all if moderation_state_visible_to_all?
      last_post = scope.select(:user_id, :created_at).first
      if last_post
        update_columns(last_user_id: last_post.user_id, last_post_at: last_post.created_at, updated_at: Time.zone.now)
      else
        # Either a visible topic is left with no visible posts, or an invisible topic is left with no posts at all.
        # This shouldn't happen in stock Thredded.
        update_columns(last_user_id: nil, last_post_at: created_at, updated_at: Time.zone.now)
      end
    end

    def should_generate_new_friendly_id?
      title_changed?
    end

    def normalize_friendly_id(input)
      Thredded.slugifier.call(input.to_s)
    end

    private

    def slug_candidates
      [
        :title,
        [:title, '-', messageboard.try(:name)],
        [:title, '-', messageboard.try(:name), '-topic']
      ]
    end

    def update_messageboard_last_topic
      messageboard.update_last_topic!
    end

    def handle_messageboard_change_after_commit
      # Update `messageboard_id` columns. These columns are a performance optimization,
      # so use update_all to avoid validitaing, triggering callbacks, and updating the timestamps:
      posts.update_all(messageboard_id: messageboard_id)
      user_read_states.update_all(messageboard_id: messageboard_id)

      # Update the associated messageboard metadata that Rails does not update them automatically.
      previous_changes['messageboard_id'].each do |messageboard_id|
        Thredded::Messageboard.reset_counters(messageboard_id, :topics, :posts)
        Thredded::Messageboard.find(messageboard_id).update_last_topic!
      end
    end
  end
end
