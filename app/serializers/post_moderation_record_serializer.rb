# frozen_string_literal: true

class PostModerationRecordSerializer
  include JSONAPI::Serializer
  attributes :previous_moderation_state, :moderation_state, :created_at
  belongs_to :messageboard
  belongs_to :post
  belongs_to :moderator, serializer: UserSerializer
  belongs_to :post_user, serializer: UserSerializer
end
