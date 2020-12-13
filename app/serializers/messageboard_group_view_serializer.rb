# frozen_string_literal: true

class MessageboardGroupViewSerializer
  include FastJsonapi::ObjectSerializer
  attribute :messageboards do |messageboards|
    MessageboardViewSerializer.new(messageboards.messageboards)
  end
end