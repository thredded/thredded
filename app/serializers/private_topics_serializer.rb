# frozen_string_literal: true

class PrivateTopicsSerializer
  include JSONAPI::Serializer
  attributes :id, :title, :user_names, :content
end