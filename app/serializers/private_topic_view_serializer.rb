# frozen_string_literal: true

class PrivateTopicViewSerializer
  include JSONAPI::Serializer
  attribute :topic do |topic|
    PrivateTopicSerializer.new(topic.topic)
  end
end