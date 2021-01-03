# frozen_string_literal: true

class PrivatePostSerializer
  # TODO only used in private_post_permalinks_controller yet (SHOW-Action) and not tested, since I couldnt create private posts. Please change attributes if required
  include JSONAPI::Serializer
  set_type :private_post
  attributes :user_id, :content, :postable_id
  belongs_to :user, serializer: UserSerializer, record_type: :user
  belongs_to :postable, serializer: PrivateTopicSerializer, record_type: :private_topics
end