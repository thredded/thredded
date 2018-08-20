# frozen_string_literal: true

module Thredded
  # The state of a user with regards to a messageboard, such as the last time the user was active (visited)
  # the messageboard.
  class MessageboardUser < ActiveRecord::Base
    belongs_to :messageboard,
               class_name:  'Thredded::Messageboard',
               foreign_key: :thredded_messageboard_id,
               inverse_of:  :messageboard_users
    belongs_to :user_detail,
               class_name: 'Thredded::UserDetail',
               foreign_key: :thredded_user_detail_id,
               inverse_of: :messageboard_users
    scope :recently_active, -> { where(arel_table[:last_seen_at].gt(Thredded.active_user_threshold.ago)) }
  end
end
