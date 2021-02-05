# frozen_string_literal: true

class MessageboardGroupViewSerializer
  include JSONAPI::Serializer
  has_one :group, serializer: MessageboardGroupSerializer
  has_many :messageboards, serializer: MessageboardViewSerializer
end
