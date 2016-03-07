module Thredded
  class PrivateUser < ActiveRecord::Base
    belongs_to :private_topic
    belongs_to :user, class_name: Thredded.user_class
  end
end
