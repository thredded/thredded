# frozen_string_literal: true

class MessageboardPreferencesSerializer
  include JSONAPI::Serializer
  attributes :follow_topics_on_mention, :auto_follow_topics
end
