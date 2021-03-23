# frozen_string_literal: true

class PostSerializer
  include JSONAPI::Serializer
  attributes :content, :source, :moderation_state, :created_at, :updated_at
  belongs_to :user, serializer: UserShowSerializer
  belongs_to :messageboard
  belongs_to :postable, serializer: TopicSerializer
end
