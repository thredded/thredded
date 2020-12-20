# frozen_string_literal: true

class TopicsPageViewSerializer
  include JSONAPI::Serializer
  attributes :topic_views
  attribute :topic_views do |topic_views|
    topic_views.topic_views.map do |topic_view|
      TopicViewSerializer.new(topic_view)
    end
  end
end