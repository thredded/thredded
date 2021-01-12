# frozen_string_literal: true

class PrivateTopicSerializer
  include JSONAPI::Serializer
  attributes :id, :title, :created_at, :updated_at
  belongs_to :user, serializer: UserSerializer
  has_many :users, serializer: UserSerializer
end