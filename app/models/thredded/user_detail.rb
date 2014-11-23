module Thredded
  class UserDetail < ActiveRecord::Base
    belongs_to :user, class_name: Thredded.user_class
    validates :user_id, presence: true

    has_many :topics, class_name: 'Thredded::Topic', foreign_key: :user_id, primary_key: :user_id
    has_many :posts, class_name: 'Thredded::Post', foreign_key: :user_id, primary_key: :user_id
  end
end
