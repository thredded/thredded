# frozen_string_literal: true
module Thredded
  class PostModerationRecord < ActiveRecord::Base
    include ModerationState
    # Rails 4 doesn't support enum _prefix
    if Rails::VERSION::MAJOR >= 5
      enum previous_moderation_state: moderation_states, _prefix: :previous
    end
    validates :previous_moderation_state, presence: true

    belongs_to :messageboard, inverse_of: :post_moderation_records
    validates :messageboard_id, presence: true
    belongs_to :post, inverse_of: :moderation_records
    belongs_to :post_user, class_name: Thredded.user_class, inverse_of: :thredded_post_moderation_records
    belongs_to :moderator, class_name: Thredded.user_class, inverse_of: :thredded_post_moderation_records

    validates_each :moderation_state do |record, attr, value|
      if record.previous_moderation_state == value
        record.errors.add attr, "Post moderation_state is already #{value}"
      end
    end

    # @param [Thredded.user_class] moderator
    # @param [Thredded::Post] post
    # @param [Symbol, String] previous_moderation_state
    # @param [Symbol, String] moderation_state
    # @return [Thredded::PostModerationRecord] the newly created persisted record
    def self.record!(moderator:, post:, previous_moderation_state:, moderation_state:)
      # Rails 4 doesn't support enum _prefix
      if Rails::VERSION::MAJOR < 5
        previous_moderation_state = moderation_states[previous_moderation_state.to_s]
      end
      create!(
        previous_moderation_state: previous_moderation_state,
        moderation_state:          moderation_state,
        moderator:                 moderator,
        post:                      post,
        post_content:              post.content,
        post_user:                 post.user,
        post_user_name:            post.user.try(:send, Thredded.user_name_column),
        messageboard_id:           post.messageboard_id,
      )
    end
  end
end
