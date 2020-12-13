# frozen_string_literal: true

class TopicPostsPageViewSerializer
  include FastJsonapi::ObjectSerializer
  attribute :topic do |topic|
    TopicViewSerializer.new(topic.topic)
  end
  attribute :post_views do |post_view|
    PostViewSerializer.new(post_view.post_views)
  end
end