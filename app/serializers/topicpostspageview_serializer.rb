# frozen_string_literal: true

class TopicpostspageviewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :post_views, :topic
end