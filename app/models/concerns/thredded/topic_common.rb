# frozen_string_literal: true
module Thredded
  module TopicCommon
    extend ActiveSupport::Concern
    included do
      paginates_per 50 if respond_to?(:paginates_per)

      belongs_to :last_user,
                 class_name:  Thredded.user_class,
                 foreign_key: 'last_user_id'

      scope :order_recently_updated_first, -> { order(updated_at: :desc, id: :desc) }
      scope :on_page, -> page_num { page(page_num).per(30) }

      validates :hash_id, presence: true, uniqueness: true
      validates :last_user_id, presence: true
      validates :posts_count, numericality: true

      before_validation do
        self.hash_id = SecureRandom.hex(10) if hash_id.nil?
      end

      delegate :name, :name=, :email, :email=, to: :user, prefix: true
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

    module ClassMethods
      # @param user [Thredded.user_class]
      # @return [ActiveRecord::Relation]
      def unread(user)
        topics      = arel_table
        reads_class = reflect_on_association(:user_read_states).klass
        reads       = reads_class.arel_table
        joins(topics.join(reads, Arel::Nodes::OuterJoin)
                .on(topics[:id].eq(reads[:postable_id]).and(reads[:user_id].eq(user.id))).join_sources)
          .merge(reads_class.where(reads[:id].eq(nil).or(reads[:read_at].lt(topics[:updated_at]))))
      end

      private

      # @param user [Thredded.user_class]
      # @return [ByPostableLookup]
      def read_states_by_topics_lookup(user, null_value)
        read_states = reflect_on_association(:user_read_states).klass
          .where(user_id: user.id, postable_id: current_scope.map(&:id))
        Thredded::TopicCommon::Lookup.new(read_states, null_value)
      end

      public

      # @param user [Thredded.user_class]
      # @return [Array<[TopicCommon, UserTopicReadStateCommon]>]
      def with_read_states(user)
        null_read_state = Thredded::NullUserTopicReadState.new
        return current_scope.zip([null_read_state]) if user.thredded_anonymous?
        read_states_by_topics = read_states_by_topics_lookup(user, null_read_state)
        current_scope.map do |topic|
          [topic, read_states_by_topics.get(topic)]
        end
      end
    end

    class Lookup
      # @param postable_related [ActiveRecord::Relation<UserTopicReadStateCommon, UserTopicFollow]
      # @param null_value [NullUserTopicReadState, nil]
      def initialize(postable_related, null_value = nil)
        @related_by_postable_id = postable_related.map { |rs| [rs.postable_id, rs] }.to_h
        @null_value = null_value
      end

      # @param postable [TopicCommon]
      # @return [UserTopicReadStateCommon, UserTopicFollow]
      def get(postable)
        related = @related_by_postable_id[postable.id]
        return @null_value unless related
        related.tap { related.postable = postable }
      end
    end
  end
end
