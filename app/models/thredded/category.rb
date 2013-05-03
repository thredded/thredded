module Thredded
  class Category < ActiveRecord::Base
    attr_accessible :description, :messageboard_id, :name
    validates :name, presence: true

    belongs_to :messageboard
    has_many :topic_categories
    has_many :topics, through: :topic_categories
  end
end
