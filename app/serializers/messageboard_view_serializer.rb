# frozen_string_literal: true

class MessageboardViewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :topics_count, :posts_count, :unread_topics_count, :unread_followed_topics_count
  attribute :messageboard do |messageboard|
    MessageboardSerializer.new(messageboard.messageboard, include: [:messageboard_group])
  end
end