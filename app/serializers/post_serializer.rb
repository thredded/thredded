# frozen_string_literal: true

class PostSerializer
  include JSONAPI::Serializer
  set_type :post
  attributes :user_id, :content, :source, :postable_id, :messageboard_id, :moderation_state, :created_at, :updated_at
  belongs_to :user
  belongs_to :messageboard
end