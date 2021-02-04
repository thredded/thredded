class PreferencesSerializer
  include JSONAPI::Serializer
  attributes :follow_topics_on_mention, :auto_follow_topics

end