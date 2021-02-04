# frozen_string_literal: true

class PrivateTopicSerializer
  include JSONAPI::Serializer
  attributes :title, :slug, :posts_count, :hash_id, :last_post_at, :created_at, :updated_at
  belongs_to :user
  has_many :users, serializer: UserSerializer
end
