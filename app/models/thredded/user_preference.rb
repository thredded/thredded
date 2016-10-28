# frozen_string_literal: true
module Thredded
  class UserPreference < ActiveRecord::Base
    belongs_to :user, class_name: Thredded.user_class, inverse_of: :thredded_user_preference
    has_many :messageboard_preferences,
             class_name: 'Thredded::UserMessageboardPreference',
             primary_key: :user_id,
             foreign_key: :user_id,
             inverse_of: :user_preference
    validates :user_id, presence: true
    serialize :notifications_for_followed_topics, TruthyHashSerializer
    serialize :notifications_for_private_topics, TruthyHashSerializer
  end
end
