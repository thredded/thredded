# frozen_string_literal: true

class UserTopicReadStateSerializer
  include JSONAPI::Serializer
  attributes :unread_posts_count, :read_posts_count, :integer, :read_at, :first_unread_post_page, :last_read_post_page
  belongs_to :user
  belongs_to :messageboard
  belongs_to :postable, serializer: TopicSerializer
end
