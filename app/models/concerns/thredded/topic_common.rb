module Thredded
  module TopicCommon
    extend ActiveSupport::Concern
    included do
      paginates_per 50 if self.respond_to?(:paginates_per)

      belongs_to :user,
                 class_name: Thredded.user_class
      belongs_to :last_user,
                 class_name: Thredded.user_class,
                 foreign_key: 'last_user_id'
      belongs_to :messageboard,
                 counter_cache: true,
                 touch: true

      scope :order_latest_first, -> { order(updated_at: :desc, id: :desc) }
      scope :for_messageboard, -> messageboard { where(messageboard_id: messageboard.id) }
      scope :on_page, -> page_num { page(page_num).per(30) }

      validates_presence_of :hash_id
      validates_presence_of :last_user_id
      validates_presence_of :messageboard_id
      validates_numericality_of :posts_count
      validates_uniqueness_of :hash_id

      before_validation do
        self.hash_id = SecureRandom.hex(10) if hash_id.nil?
      end

      delegate :name, :name=, :email, :email=, to: :user, prefix: true

      def user
        super || NullUser.new
      end

      def last_user
        super || NullUser.new
      end
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
