# frozen_string_literal: true

class MessageboardGroupSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :position, :created_at, :updated_at
  has_many :messageboards
end
