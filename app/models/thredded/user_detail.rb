# frozen_string_literal: true
module Thredded
  class UserDetail < ActiveRecord::Base
    belongs_to :user, class_name: Thredded.user_class, inverse_of: :thredded_user_detail
    validates :user_id, presence: true

    has_many :topics, class_name: 'Thredded::Topic', foreign_key: :user_id, primary_key: :user_id
    has_many :posts, class_name: 'Thredded::Post', foreign_key: :user_id, primary_key: :user_id
    has_many :private_posts, class_name: 'Thredded::PrivatePost', foreign_key: :user_id, primary_key: :user_id

    scope :recently_active, -> { where(arel_table[:last_seen_at].gt(Thredded.active_user_threshold.ago)) }
  end
end
