# frozen_string_literal: true

class PrivatePostSerializer
  # TODO only used in private_post_permalinks_controller yet (SHOW-Action) and not tested, since I couldnt create private posts. Please change attributes if required
  include JSONAPI::Serializer
  set_type :private_post
  attributes :user_id, :content, :source, :postable_id, :messageboard_id, :moderation_state, :created_at, :updated_at
  belongs_to :user
end