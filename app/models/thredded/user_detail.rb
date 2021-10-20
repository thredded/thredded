# frozen_string_literal: true

module Thredded
  class UserDetail < ActiveRecord::Base
    include Thredded::ModerationState

    belongs_to :user, class_name: Thredded.user_class_name, inverse_of: :thredded_user_detail
    validates :user_id,
              uniqueness: { case_sensitive: true },
              presence: true

    with_options foreign_key: :user_id, primary_key: :user_id, inverse_of: :user_detail, dependent: :nullify do
      has_many :topics, class_name: 'Thredded::Topic'
      has_many :private_topics, class_name: 'Thredded::PrivateTopic'
      has_many :posts, class_name: 'Thredded::Post'
      has_many :private_posts, class_name: 'Thredded::PrivatePost'
    end

    has_many :messageboard_users,
             class_name: 'Thredded::MessageboardUser',
             foreign_key: :thredded_user_detail_id,
             inverse_of: :user_detail,
             dependent: :delete_all

    scope :recently_active, -> { where(arel_table[:last_seen_at].gt(Thredded.active_user_threshold.ago)) }

    before_save :set_moderation_state_changed_at

    private

    def set_moderation_state_changed_at
      self.moderation_state_changed_at = Time.current if moderation_state_changed?
    end
  end
end
