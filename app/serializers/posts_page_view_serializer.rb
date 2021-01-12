# frozen_string_literal: true

class PostsPageViewSerializer
  include JSONAPI::Serializer
  attribute :author do |posts_page_view|
    UserSerializer.new(posts_page_view.author)
  end
  attribute :post_views do |posts_page_view|
    PostViewSerializer.new(posts_page_view.post_views)
  end
end