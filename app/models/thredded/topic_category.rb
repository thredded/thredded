# frozen_string_literal: true

module Thredded
  class TopicCategory < ActiveRecord::Base
    belongs_to :category, inverse_of: :topic_categories
    belongs_to :topic, inverse_of: :topic_categories
  end
end
