# frozen_string_literal: true

class PrivateTopicViewSerializer
  include JSONAPI::Serializer
  has_one :topic,
          serializer: PrivateTopicSerializer

  has_one :read_state,
          serializer: UserPrivateTopicReadStateSerializer,
          if: proc { |private_topic_view| private_topic_view.read_state.is_a?(Thredded::UserPrivateTopicReadState) }
end
