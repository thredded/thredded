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

      validates_presence_of :hash_id
      validates_presence_of :last_user_id
      validates_numericality_of :posts_count
      validates_uniqueness_of :hash_id

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

      def decorate
        all.map do |topic|
          TopicDecorator.new(topic)
        end
      end
    end
  end
end
