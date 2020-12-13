# frozen_string_literal: true

class TopicPostsPageViewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :post_views, :topic
end