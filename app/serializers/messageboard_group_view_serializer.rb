# frozen_string_literal: true

class MessageboardGroupViewSerializer
  include JSONAPI::Serializer
  attribute :messageboards do |messageboards|
    MessageboardViewSerializer.new(messageboards.messageboards)
  end
end