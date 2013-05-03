module Thredded
  class TopicCategory < ActiveRecord::Base
    attr_accessible :category_id, :topic_id
    belongs_to :category
    belongs_to :topic
  end
end
