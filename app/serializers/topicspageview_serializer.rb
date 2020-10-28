# frozen_string_literal: true

class TopicspageviewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id , :topic_views
end