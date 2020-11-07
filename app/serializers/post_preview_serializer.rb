# frozen_string_literal: true

class MessageboardgroupviewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :messageboards, :group
end