# frozen_string_literal: true

class PostSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :content, :source, :messageboard_id, :moderation_state
end