# frozen_string_literal: true

class TopicSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :user_id, :last_user_id, :title, :slug, :messageboard_id, :posts_count, :sticky, :locked, :hash_id, :moderation_state, :last_post_at, :created_at, :updated_at
  belongs_to :messageboard, serializer: MessageboardSerializer
  belongs_to :user, serializer: UserSerializer
  has_many :user_read_states, serializer: UserReadStatesSerializer
  has_many :user_follows, serializer: UserFollowsSerializer
end