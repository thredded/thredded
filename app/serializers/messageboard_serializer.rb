# frozen_string_literal: true

class MessageboardSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :description, :slug, :topics_count, :posts_count, :position, :last_topic_id, :messageboard_group_id, :locked, :created_at, :updated_at
end