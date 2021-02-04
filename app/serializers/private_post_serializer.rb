# frozen_string_literal: true

class PrivatePostSerializer
  include JSONAPI::Serializer
  attributes :content, :created_at, :updated_at
  belongs_to :user
  belongs_to :postable, serializer: PrivateTopicSerializer
end
