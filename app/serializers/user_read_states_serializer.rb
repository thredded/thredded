# frozen_string_literal: true

class UserReadStatesSerializer
  include JSONAPI::Serializer
  attributes :id, :messageboard_id, :user_id, :postable_id, :unread_posts_count, :read_posts_count, :integer, :read_at, :first_unread_post_page, :last_read_post_page
end