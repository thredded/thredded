# frozen_string_literal: true

class TopicsPageViewSerializer
  include JSONAPI::Serializer
  attribute :topic_views do |topic_page_view|
    topic_page_view.topic_views.map do |topic_view|
      TopicViewSerializer.new(topic_view)
    end
  end
end