# frozen_string_literal: true

class PostmoderationrecordSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :previous_moderation_state, :moderation_state, :moderator, :post, :post_content, :post_user, :post_user_name, :messageboard_id
end