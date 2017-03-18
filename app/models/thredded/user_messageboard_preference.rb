# frozen_string_literal: true
require_dependency 'app/models/thredded/user_preference'
module Thredded
  class UserMessageboardPreference < ActiveRecord::Base
    belongs_to :user_preference,
               primary_key: :user_id,
               foreign_key: :user_id,
               inverse_of: :messageboard_preferences
    belongs_to :user,
               class_name: Thredded.user_class,
               inverse_of: :thredded_user_messageboard_preferences
    belongs_to :messageboard

    validates :user_id, presence: true
    validates :messageboard_id, presence: true

    # If we're migrating from a version that doesn't have the column, this check will fail.
    if Thredded::UserPreference.new.respond_to?(:auto_follow_topics?)
      attribute :auto_follow_topics, ActiveRecord::Type::Boolean.new,
                default: Thredded::UserPreference.new.auto_follow_topics?
    end

    scope :auto_followers, -> { where(auto_follow_topics: true) }

    def self.in(messageboard)
      find_or_initialize_by(messageboard_id: messageboard.id)
    end

    def user_preference
      super || build_user_preference
    end
  end
end
