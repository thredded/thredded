module Thredded
  class Category < ActiveRecord::Base
    belongs_to :messageboard
    has_many :topic_categories
    has_many :topics, through: :topic_categories

    validates :name, presence: true
    validates :messageboard_id, presence: true
  end
end
