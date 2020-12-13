# frozen_string_literal: true

class PostModerationRecordSerializer
  include FastJsonapi::ObjectSerializer
  set_type :post_moderation_record
  attributes :id, :previous_moderation_state, :moderation_state
  belongs_to :messageboard
  belongs_to :post
  belongs_to :moderator, serializer: UserSerializer, record_type: :user
  belongs_to :post_user, serializer: UserSerializer, record_type: :user
end