# frozen_string_literal: true

class TopicsPageViewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :topic_views
  attribute :topic_views do |topic_views|
    topic_views.topic_views.map do |topic_view|
      TopicSerializer.new(topic_view.topic,  include: [:messageboard, :user, :user_read_states, :user_follows])
    end
  end
end