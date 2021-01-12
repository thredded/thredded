# frozen_string_literal: true

class PostModerationRecordSerializer
  include JSONAPI::Serializer
  set_type :post_moderation_record
  attributes :previous_moderation_state, :moderation_state, :created_at
  belongs_to :messageboard
  belongs_to :post
  belongs_to :moderator, serializer: UserSerializer, record_type: :user
  belongs_to :post_user, serializer: UserSerializer, record_type: :user
end