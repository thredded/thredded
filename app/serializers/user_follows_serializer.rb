# frozen_string_literal: true

class UserFollowsSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :user_id, :topic_id, :created_at, :reason
end