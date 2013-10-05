module Thredded
  class PostNotification < ActiveRecord::Base
    belongs_to :post
  end
end
