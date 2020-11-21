# frozen_string_literal: true

class PostsPageViewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :author, :post_views
end