# frozen_string_literal: true

module Thredded
  class TopicCategory < ActiveRecord::Base
    belongs_to :category
    belongs_to :topic
  end
end
