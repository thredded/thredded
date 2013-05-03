module Thredded
  class PostNotification < ActiveRecord::Base
    attr_accessible :email, :post_id
    belongs_to :post
  end
end
