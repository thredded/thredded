# frozen_string_literal: true

class TopicSerializer
  include JSONAPI::Serializer
  attributes :title, :slug, :posts_count, :sticky, :locked, :hash_id, :moderation_state, :last_post_at, :type, :video_url, :movie_categories, :view_count, :created_at, :updated_at
  belongs_to :messageboard
  belongs_to :user
  belongs_to :last_user, serializer: UserSerializer, record_type: :user
end