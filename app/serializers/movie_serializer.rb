class MovieSerializer
  include JSONAPI::Serializer
  attributes :title, :slug, :posts_count, :sticky, :locked, :hash_id, :moderation_state, :last_post_at, :type, :video_url, :view_count, :created_at, :updated_at
  has_many :categories
end