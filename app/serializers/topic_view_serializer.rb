# frozen_string_literal: true

class TopicViewSerializer
  include JSONAPI::Serializer
  attribute :topic do |topic_view|
    TopicSerializer.new(topic_view.topic, include: [:messageboard, :user, :last_user])
  end
  attribute :follow do |topic_view|
    if topic_view.follow.is_a?(Thredded::UserTopicFollow)
      UserTopicFollowSerializer.new(topic_view.follow)
    end
  end
  attribute :read_state do |topic_view|
    if topic_view.read_state.is_a?(Thredded::UserTopicReadState)
      UserTopicReadStateSerializer.new(topic_view.read_state)
    end
  end
end