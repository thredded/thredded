# frozen_string_literal: true

class PostformSerializer
  include FastJsonapi::ObjectSerializer
  attributes :content, :source, :messageboard_id, :moderation_state
end