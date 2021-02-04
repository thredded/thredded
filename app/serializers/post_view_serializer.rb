# frozen_string_literal: true

class PostViewSerializer
  include JSONAPI::Serializer
  attributes :first_unread_in_page, :first_in_page
  has_one :post, polymorphic: true
end
