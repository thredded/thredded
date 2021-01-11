# frozen_string_literal: true

class PrivatePostViewSerializer
  include JSONAPI::Serializer
  attributes :id
  attribute :post do |post|
    PostSerializer.new(post.post, include: [:user])
  end
end