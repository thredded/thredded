# frozen_string_literal: true

class MessageboardGroupViewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :messageboards, :group
end