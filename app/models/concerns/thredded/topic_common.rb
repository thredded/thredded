# frozen_string_literal: true

module Thredded
  module TopicCommon
    extend ActiveSupport::Concern
    included do
      paginates_per Thredded.topics_per_page if respond_to?(:paginates_per)

      belongs_to :last_user, # rubocop:disable Rails/InverseOf
                 class_name: Thredded.user_class_name,
                 foreign_key: 'last_user_id',
                 **(Thredded.rails_gte_51? ? { optional: true } : {})

      scope :order_recently_posted_first, -> { order(last_post_at: :desc, id: :desc) }
      scope :on_page, ->(page_num) { page(page_num) }

      validates :hash_id, presence: true, uniqueness: true
      validates :posts_count, numericality: true

      validates :title, presence: true, length: { within: Thredded.topic_title_length_range }

      before_validation do
        self.hash_id = SecureRandom.hex(10) if hash_id.nil?
      end

      delegate :name, :name=, :email, :email=, to: :user, prefix: true

      before_validation :ensure_user_detail, on: :create
    end

    def user
      super || Thredded::NullUser.new
    end

    def last_user
      super || Thredded::NullUser.new
    end

    def private?
      !public?
    end

    private

    def ensure_user_detail
      build_user_detail if user && !user_detail
    end

    module ClassMethods
      # @param user [Thredded.user_class]
      # @return [ActiveRecord::Relation]
      def unread(user)
        topics = arel_table
        reads_class = reflect_on_association(:user_read_states).klass
        reads = reads_class.arel_table

        joins_reads =
          topics.outer_join(reads)
            .on(topics[:id].eq(reads[:postable_id]).and(reads[:user_id].eq(user.id))).join_sources

        unread_scope = reads_class.where(reads[:id].eq(nil).or(reads[:unread_posts_count].not_eq(0)))

        # Work around https://github.com/rails/rails/issues/36761
        if Thredded.rails_gte_600_rc_2?
          merge(unread_scope).joins(joins_reads)
        else
          joins(joins_reads).merge(unread_scope)
        end
      end

      private

      # @param user [Thredded.user_class]
      # @return [ByPostableLookup]
      def read_states_by_postable_hash(user)
        read_states = reflect_on_association(:user_read_states).klass
          .where(user_id: user.id, postable_id: current_scope.map(&:id))
          .with_page_info
        Thredded::TopicCommon::CachingHash.from_relation(read_states)
      end

      # @param [Thredded.user_class] user
      # @param [Array<Number>] topic_ids
      # @return [Hash{topic ID => posts count}] Counts of posts visible to the given user in the given topics.
      def post_counts_for_user_and_topics(user, topic_ids)
        return {} if topic_ids.empty?
        Pundit.policy_scope!(user, post_class.all).where(postable_id: topic_ids).group(:postable_id).count
      end
    end

    class CachingHash < Hash
      def self.from_relation(postable_relation)
        self[postable_relation.map { |related| [related.postable_id, related] }]
      end

      # lookup related item by postable and set the inverse lookup
      def [](postable)
        super(postable.id).tap { |related| related.postable = postable if related }
      end
    end
  end
end
