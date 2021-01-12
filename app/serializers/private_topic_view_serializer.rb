# frozen_string_literal: true

class PrivateTopicViewSerializer
  include JSONAPI::Serializer
  attribute :topic do |topic|
    PrivateTopicSerializer.new(topic.topic, include: [:user, :users])
  end
  attribute :read_state do |read_state|
    if read_state.read_state.is_a?(Thredded::UserPrivateTopicReadState)
      UserPrivateTopicReadStateSerializer.new(read_state.read_state)
    end
  end
end