# frozen_string_literal: true

class TopicViewSerializer
  include JSONAPI::Serializer
  has_one :topic
  has_one :read_state, serializer: UserTopicReadStateSerializer, if: proc { |topic_view| topic_view.read_state.is_a?(Thredded::UserTopicReadState) }
  has_one :follow, serializer: UserTopicFollowSerializer, if: proc { |topic_view| topic_view.follow.is_a?(Thredded::UserTopicFollow) }
  has_many :categories
end
