# frozen_string_literal: true

class PrivateTopicViewSerializer
  include JSONAPI::Serializer
  attribute :topic do |private_topic_view|
    PrivateTopicSerializer.new(private_topic_view.topic, include: [:user, :users])
  end
  attribute :read_state do |private_topic_view|
    if private_topic_view.read_state.is_a?(Thredded::UserPrivateTopicReadState)
      UserPrivateTopicReadStateSerializer.new(private_topic_view.read_state)
    end
  end
end