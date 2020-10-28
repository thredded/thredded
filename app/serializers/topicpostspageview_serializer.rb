# frozen_string_literal: true

class TopicpostspageviewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :post_views, :topic
end