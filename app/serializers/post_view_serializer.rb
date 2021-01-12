# frozen_string_literal: true

class PostViewSerializer
  include JSONAPI::Serializer
  attributes :first_unread_in_page, :first_in_page
  attribute :post do |post_view|
    if post_view.post.is_a?(Thredded::PrivatePost)
      PrivatePostSerializer.new(post_view.post, include: [:user])
    else
      PostSerializer.new(post_view.post, include: [:user])
    end
  end
end