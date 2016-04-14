# frozen_string_literal: true
module Thredded
  module TopicCommon
    extend ActiveSupport::Concern
    included do
      paginates_per 50 if respond_to?(:paginates_per)

      belongs_to :last_user,
                 class_name: Thredded.user_class,
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
      def decorate
        all.map do |topic|
          TopicDecorator.new(topic)
        end
      end
    end
  end
end
