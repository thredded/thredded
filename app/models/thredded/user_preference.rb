module Thredded
  class UserPreference < ActiveRecord::Base
    belongs_to :user, class_name: Thredded.user_class
    validates :user_id, presence: true
  end
end
