# frozen_string_literal: true
module Thredded
  module TopicCommon
    extend ActiveSupport::Concern
    included do
      paginates_per 50 if respond_to?(:paginates_per)

      belongs_to :last_user,
                 class_name:  Thredded.user_class,
                 foreign_key: 'last_user_id'

      scope :order_recently_posted_first, -> { order(last_post_at: :desc, id: :desc) }
      scope :on_page, -> (page_num) { page(page_num) }

      validates :hash_id, presence: true, uniqueness: true
      validates :posts_count, numericality: true

      before_validation do
        self.hash_id = SecureRandom.hex(10) if hash_id.nil?
      end

      delegate :name, :name=, :email, :email=, to: :user, prefix: true

      before_validation :ensure_user_detail, on: :create
    end

    def user
      super || NullUser.new
    end

    def last_user
      super || NullUser.new
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
        topics      = arel_table
        reads_class = reflect_on_association(:user_read_states).klass
        reads       = reads_class.arel_table
        joins(topics.join(reads, Arel::Nodes::OuterJoin)
                .on(topics[:id].eq(reads[:postable_id]).and(reads[:user_id].eq(user.id))).join_sources)
          .merge(reads_class.where(reads[:id].eq(nil).or(reads[:read_at].lt(topics[:last_post_at]))))
      end

      private

      # @param user [Thredded.user_class]
      # @return [ByPostableLookup]
      def read_states_by_postable_hash(user)
        read_states = reflect_on_association(:user_read_states).klass
          .where(user_id: user.id, postable_id: current_scope.map(&:id))
        Thredded::TopicCommon::CachingHash.from_relation(read_states)
      end

      public

      # @param user [Thredded.user_class]
      # @return [Array<[TopicCommon, UserTopicReadStateCommon]>]
      def with_read_states(user)
        null_read_state = Thredded::NullUserTopicReadState.new
        return current_scope.zip([null_read_state]) if user.thredded_anonymous?
        read_states_by_postable = read_states_by_postable_hash(user)
        current_scope.map do |postable|
          [postable, read_states_by_postable[postable] || null_read_state]
        end
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
