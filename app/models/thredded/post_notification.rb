module Thredded
  class PostNotification < ActiveRecord::Base
    belongs_to :post
    validates :email, presence: true
    validates :post_id, presence: true
  end
end
