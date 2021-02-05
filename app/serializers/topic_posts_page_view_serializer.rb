# frozen_string_literal: true

class TopicPostsPageViewSerializer
  include JSONAPI::Serializer
  has_one :topic, polymorphic: true
  has_many :post_views
  has_many :categories
end
