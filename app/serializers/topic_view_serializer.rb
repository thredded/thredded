# frozen_string_literal: true

class TopicViewSerializer
  include JSONAPI::Serializer
  attribute :topic do |topic|
    TopicSerializer.new(topic.topic, include: [:messageboard, :user, :last_user])
  end
  attribute :follow do |follow|
    if follow.follow.is_a?(Thredded::UserTopicFollow)
      UserFollowsSerializer.new(follow.follow)
    end
  end
  attribute :read_state do |read_state|
    if read_state.read_state.is_a?(Thredded::UserTopicReadState)
      UserReadStatesSerializer.new(read_state.read_state)
    end
  end
end