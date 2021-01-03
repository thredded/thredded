# frozen_string_literal: true

class PrivateTopicUpdateSerializer
  include JSONAPI::Serializer
  attributes :id, :title
end