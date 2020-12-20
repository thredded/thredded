# frozen_string_literal: true

class MessageboardViewSerializer
  include JSONAPI::Serializer
  attributes :id, :topics_count, :posts_count, :unread_topics_count, :unread_followed_topics_count
  attribute :messageboard do |messageboard|
    MessageboardSerializer.new(messageboard.messageboard, include: [:messageboard_group, :last_user, :last_topic])
  end
end