# frozen_string_literal: true

class TopicSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :user_id, :last_user_id, :title, :slug, :messageboard_id, :posts_count, :sticky, :locked, :moderation_state
end