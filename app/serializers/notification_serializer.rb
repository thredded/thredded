# frozen_string_literal: true

class NotificationSerializer
  include JSONAPI::Serializer
  attributes :name, :description, :url, :created_at, :updated_at
end
