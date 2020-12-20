# frozen_string_literal: true

class TopicSerializer
  include JSONAPI::Serializer
  attributes :id, :user_id, :last_user_id, :title, :slug, :messageboard_id, :posts_count, :sticky, :locked, :hash_id, :moderation_state, :last_post_at, :created_at, :updated_at
  belongs_to :messageboard, serializer: MessageboardSerializer
  belongs_to :user, serializer: UserSerializer
  belongs_to :last_user, serializer: UserSerializer, record_type: :user
end