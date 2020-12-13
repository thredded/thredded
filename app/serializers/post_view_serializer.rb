# frozen_string_literal: true

class PostViewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :first_unread_in_page, :first_in_page
  attribute :post do |post|
    PostSerializer.new(post.post, include: [:user])
  end
end