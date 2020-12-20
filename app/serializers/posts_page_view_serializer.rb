# frozen_string_literal: true

class PostsPageViewSerializer
  include JSONAPI::Serializer
  attribute :author do |author|
    UserSerializer.new(author.author)
  end
  attribute :post_views do |post_views|
    PostViewSerializer.new(post_views.post_views)
  end
end