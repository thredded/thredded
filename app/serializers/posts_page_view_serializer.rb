# frozen_string_literal: true

class PostsPageViewSerializer
  include JSONAPI::Serializer
  has_one :author, serializer: UserSerializer
  has_many :post_views
end