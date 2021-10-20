# frozen_string_literal: true

module Thredded
  class Messageboard < ActiveRecord::Base
    extend FriendlyId
    friendly_id :slug_candidates,
                use: %i[slugged reserved],
                # Avoid route conflicts
                reserved_words: ::Thredded::FriendlyIdReservedWordsAndPagination.new(
                  %w[
                    action
                    admin
                    autocomplete-users
                    messageboards
                    messageboard-groups
                    posts
                    preferences
                    private-posts
                    private-topics
                    theme-preview
                    unread
                  ]
                )

    validates :name,
              uniqueness: { case_sensitive: false },
              length: { within: Thredded.messageboard_name_length_range },
              presence: true
    validates :topics_count, numericality: true
    validates :position, presence: true, on: :update
    before_save :ensure_position

    def ensure_position
      self.position ||= (created_at || Time.zone.now).to_i
    end

    has_many :categories, dependent: :destroy
    has_many :user_messageboard_preferences, dependent: :destroy
    has_many :posts, dependent: :destroy, inverse_of: :messageboard
    has_many :topics, dependent: :destroy, inverse_of: :messageboard

    belongs_to :last_topic, class_name: 'Thredded::Topic', optional: true

    has_many :user_details, through: :posts
    has_many :messageboard_users,
             inverse_of:  :messageboard,
             foreign_key: :thredded_messageboard_id,
             dependent: :destroy
    has_many :recently_active_user_details,
             -> { merge(Thredded::MessageboardUser.recently_active) },
             class_name: 'Thredded::UserDetail',
             through:    :messageboard_users,
             source:     :user_detail
    has_many :recently_active_users,
             class_name: Thredded.user_class_name,
             through:    :recently_active_user_details,
             source:     :user

    has_many :user_topic_read_states,
             class_name: 'Thredded::UserTopicReadState',
             inverse_of: :messageboard,
             dependent: :delete_all

    belongs_to :group,
               inverse_of: :messageboards,
               foreign_key: :messageboard_group_id,
               class_name: 'Thredded::MessageboardGroup',
               optional: true

    has_many :post_moderation_records, inverse_of: :messageboard, dependent: :delete_all
    scope :top_level_messageboards, -> { where(group: nil) }
    scope :by_messageboard_group, ->(group) { where(group: group.id) }
    scope :ordered, ->(order = Thredded.messageboards_order) {
      case order
      when :position
        self
      when :created_at_asc
        ordered_by_created_at_asc
      when :last_post_at_desc
        ordered_by_last_post_at_desc
      when :topics_count_desc
        ordered_by_topics_count_desc
      end.ordered_by_position.order(id: :asc)
    }
    scope :ordered_by_position, -> { order(position: :asc) }
    scope :ordered_by_created_at_asc, -> { order(created_at: :asc) }
    scope :ordered_by_last_post_at_desc, -> {
      joins('LEFT JOIN thredded_topics AS last_topics ON thredded_messageboards.last_topic_id = last_topics.id')
        .order(Arel.sql('COALESCE(last_topics.last_post_at, thredded_messageboards.created_at) DESC'))
    }
    scope :ordered_by_topics_count_desc, -> {
      order(topics_count: :desc)
    }

    # Finds the messageboard by its slug or ID, or raises Thredded::Errors::MessageboardNotFound.
    # @param slug_or_id [String]
    # @return [Thredded::Messageboard]
    # @raise [Thredded::Errors::MessageboardNotFound] if the messageboard with the given slug does not exist.
    def self.friendly_find!(slug_or_id)
      friendly.find(slug_or_id)
    rescue ActiveRecord::RecordNotFound
      raise Thredded::Errors::MessageboardNotFound
    end

    def last_user
      last_topic.try(:last_user)
    end

    def update_last_topic!
      return if destroyed?
      self.last_topic = topics.order_recently_posted_first.moderation_state_visible_to_all.first
      save! if last_topic_id_changed?
    end

    def normalize_friendly_id(input)
      Thredded.slugifier.call(input.to_s)
    end

    private

    def slug_candidates
      [
        :name,
        [:name, '-board']
      ]
    end

    class << self
      # @param [Thredded.user_class] user
      # @param [ActiveRecord::Relation<Thredded::Topic>] topics_scope
      def unread_topics_counts(user:, topics_scope: Thredded::Topic.all)
        messageboards = arel_table
        read_states = Thredded::UserTopicReadState.arel_table
        topics = topics_scope.arel_table

        read_states_join_cond =
          messageboards[:id].eq(read_states[:messageboard_id])
            .and(read_states[:postable_id].eq(topics[:id]))
            .and(read_states[:user_id].eq(user.id))
            .and(read_states[:unread_posts_count].eq(0))

        relation = joins(:topics).merge(topics_scope).joins(
          messageboards.outer_join(read_states).on(read_states_join_cond).join_sources
        ).group(messageboards[:id])
        relation.pluck(
          :id,
          Arel::Nodes::Subtraction.new(topics[:id].count, read_states[:id].count)
        ).to_h
      end
    end
  end
end
