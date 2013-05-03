module Thredded
  class PrivateUser < ActiveRecord::Base
    attr_accessible :private_topic_id, :user_id
    belongs_to :private_topic
    belongs_to :user
  end
end
