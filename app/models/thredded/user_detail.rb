# frozen_string_literal: true
module Thredded
  class UserDetail < ActiveRecord::Base
    include ModerationState

    belongs_to :user, class_name: Thredded.user_class, inverse_of: :thredded_user_detail
    validates :user_id, presence: true, uniqueness: true

    has_many :topics, class_name: 'Thredded::Topic', foreign_key: :user_id, primary_key: :user_id
    has_many :private_topics, class_name: 'Thredded::PrivateTopic', foreign_key: :user_id, primary_key: :user_id
    has_many :posts, class_name: 'Thredded::Post', foreign_key: :user_id, primary_key: :user_id
    has_many :private_posts, class_name: 'Thredded::PrivatePost', foreign_key: :user_id, primary_key: :user_id
    has_many :messageboard_users, class_name: 'Thredded::MessageboardUser', foreign_key: :thredded_user_detail_id,
                                  inverse_of: :user_detail, dependent: :destroy

    scope :recently_active, -> { where(arel_table[:last_seen_at].gt(Thredded.active_user_threshold.ago)) }

    before_save :set_moderation_state_changed_at

    private

    def set_moderation_state_changed_at
      self.moderation_state_changed_at = Time.current if moderation_state_changed?
    end
  end
end
