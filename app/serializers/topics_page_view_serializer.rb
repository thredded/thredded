# frozen_string_literal: true

class TopicsPageViewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :topic_views
end