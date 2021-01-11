# frozen_string_literal: true

class PrivateTopicPostsPageViewSerializer
  include JSONAPI::Serializer
  attribute :topic do |topic|
    PrivateTopicViewSerializer.new(topic.topic)
  end
  attribute :post_views do |post_view|
    PrivatePostViewSerializer.new(post_view.post_views)
  end
end