# frozen_string_literal: true

class PrivatePostSerializer
  include JSONAPI::Serializer
  set_type :private_post
  attributes :user_id, :content, :postable_id
  belongs_to :user, serializer: UserSerializer, record_type: :user
  belongs_to :postable, serializer: PrivateTopicSerializer, record_type: :private_topics
end