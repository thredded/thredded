# frozen_string_literal: true

class UserPreferencesSerializer
  include JSONAPI::Serializer

  attributes :follow_topics_on_mention, :auto_follow_topics
  has_many :messageboard_preferences, serializer: MessageboardPreferencesSerializer
end
