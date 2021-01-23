# frozen_string_literal: true

class MessageboardViewSerializer
  include JSONAPI::Serializer
  attributes :topics_count, :posts_count, :unread_topics_count, :unread_followed_topics_count
  belongs_to :messageboard
end