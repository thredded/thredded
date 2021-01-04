# frozen_string_literal: true

class PrivateTopicSerializer
  include JSONAPI::Serializer
  attributes :id, :title, :user_names, :content
end