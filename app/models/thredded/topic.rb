# frozen_string_literal: true
require_dependency 'thredded/topics_search'
module Thredded
  class Topic < ActiveRecord::Base
    include TopicCommon
    include ContentModerationState

    scope :for_messageboard, -> (messageboard) { where(messageboard_id: messageboard.id) }

    scope :stuck, -> { where(sticky: true) }
    scope :unstuck, -> { where(sticky: false) }

    # Using `search_query` instead of `search` to avoid conflict with Ransack.
    scope :search_query, -> (query) { ::Thredded::TopicsSearch.new(query, self).search }

    scope :order_sticky_first, -> { order(sticky: :desc) }

    extend FriendlyId
    friendly_id :slug_candidates,
                use:            [:history, :reserved, :scoped],
                scope:          :messageboard,
                # Avoid route conflicts
                reserved_words: ::Thredded::FriendlyIdReservedWordsAndPagination.new(%w(topics))

    belongs_to :user,
               class_name: Thredded.user_class,
               inverse_of: :thredded_topics

    belongs_to :messageboard,
               counter_cache: true,
               touch: true,
               inverse_of: :topics
    validates :messageboard_id, presence: true

    belongs_to :user_detail,
               primary_key:   :user_id,
               foreign_key:   :user_id,
               inverse_of:    :topics,
               counter_cache: :topics_count

    has_many :posts,
             class_name:  'Thredded::Post',
             foreign_key: :postable_id,
             inverse_of:  :postable,
             dependent:   :destroy
    has_one :first_post, -> { order_oldest_first },
            class_name:  'Thredded::Post',
            foreign_key: :postable_id

    has_many :topic_categories, dependent: :destroy
    has_many :categories, through: :topic_categories
    has_many :user_read_states,
             class_name: 'Thredded::UserTopicReadState',
             foreign_key: :postable_id,
             inverse_of: :postable,
             dependent: :destroy
    has_many :user_follows,
             class_name: 'Thredded::UserTopicFollow',
             inverse_of: :topic,
             dependent: :destroy
    has_many :following_users,
             class_name: Thredded.user_class,
             source: :user,
             through: :user_follows

    after_commit :update_messageboard_last_topic, on: [:create, :destroy]

    def self.find_by_slug!(slug)
      friendly.find(slug)
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

      # @param user [Thredded.user_class]
      # @return [Array<[TopicCommon, UserTopicReadStateCommon, UserTopicFollow]>]
      def with_read_and_follow_states(user)
        null_read_state = Thredded::NullUserTopicReadState.new
        return current_scope.zip([null_read_state, nil]) if user.thredded_anonymous?
        read_states_by_topic = read_states_by_postable_hash(user)
        follows_by_topic = follows_by_topic_hash(user)
        current_scope.map do |topic|
          [topic, read_states_by_topic[topic] || null_read_state, follows_by_topic[topic]]
        end
      end
    end

    def public?
      true
    end

    def user_detail
      super || build_user_detail
    end

    def should_generate_new_friendly_id?
      title_changed?
    end

    # @return [Thredded::PostModerationRecord, nil]
    def last_moderation_record
      first_post.try(:last_moderation_record)
    end

    private

    def slug_candidates
      [
        :title,
        [:title, '-topic'],
      ]
    end

    def update_messageboard_last_topic
      return if messageboard.destroyed?
      last_topic = if destroyed?
                     messageboard.topics.order_recently_updated_first.select(:id).first
                   else
                     self
                   end
      messageboard.update!(last_topic_id: last_topic.try(:id))
    end
  end
end
