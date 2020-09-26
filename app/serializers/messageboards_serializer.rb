# frozen_string_literal: true

class MessageboardsSerializer
  include FastJsonapi::ObjectSerializer
  attributes :messageboards, :group
end