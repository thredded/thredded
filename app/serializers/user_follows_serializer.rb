# frozen_string_literal: true

class UserFollowsSerializer
  include JSONAPI::Serializer
  attributes :id, :user_id, :topic_id, :created_at, :reason
end