# frozen_string_literal: true

class TopicPostsPageViewSerializer
  include JSONAPI::Serializer
  attribute :topic do |topic_posts_page_view|
    if topic_posts_page_view.topic.is_a?(Thredded::PrivateTopicView)
      PrivateTopicViewSerializer.new(topic_posts_page_view.topic)
    else
      TopicViewSerializer.new(topic_posts_page_view.topic)
    end
  end
  attribute :post_views do |topic_posts_page_view|
    PostViewSerializer.new(topic_posts_page_view.post_views)
  end
end