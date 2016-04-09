module Thredded
  class UserDetail < ActiveRecord::Base
    belongs_to :user, class_name: Thredded.user_class, inverse_of: :thredded_user_detail
    validates :user_id, presence: true

    has_many :topics, class_name: 'Thredded::Topic', foreign_key: :user_id, primary_key: :user_id
    has_many :posts, class_name: 'Thredded::Post', foreign_key: :user_id, primary_key: :user_id
    has_many :private_posts, class_name: 'Thredded::PrivatePost', foreign_key: :user_id, primary_key: :user_id

    scope :recently_active, -> { where(arel_table[:last_seen_at].gt(Thredded.active_user_threshold.ago)) }

    # Find or create and return a {UserDetail} for a given user.
    # @param user [Thredded.user_class]
    # @return [Thredded::UserDetail] a persisted UserDetail.
    def self.for_user(user)
      for_user_id(user.id)
    end

    # Find or create and return a {UserDetail} for a given user ID.
    # @param user_id [Fixnum, String]
    # @return [Thredded::UserDetail] a persisted UserDetail.
    def self.for_user_id(user_id)
      where(user_id: user_id).first_or_create!
    end
  end
end
