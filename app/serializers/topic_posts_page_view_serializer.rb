# frozen_string_literal: true

class TopicPostsPageViewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id
  attribute :topic do |topic|
    TopicSerializer.new(topic.topic.topic, include: [:messageboard, :user, :user_read_states, :user_follows])
  end
  attribute :post_views do |post_view|
    PostViewSerializer.new(post_view.post_views)
  end
end