module Thredded
  class PrivateUser < ActiveRecord::Base
    belongs_to :private_topic
    belongs_to :user
  end
end
