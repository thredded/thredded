# frozen_string_literal: true

class UserTopicFollowSerializer
  include JSONAPI::Serializer
  attributes :reason, :created_at
  belongs_to :user
  belongs_to :topic
end