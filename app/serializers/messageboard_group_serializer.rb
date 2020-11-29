# frozen_string_literal: true

class MessageboardGroupSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :position, :created_at, :updated_at
end