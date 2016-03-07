module Thredded
  # Keeps track of post notifications that have been sent already.
  class PostNotification < ActiveRecord::Base
    belongs_to :post, polymorphic: true
    # Specific post type associations for joins
    belongs_to :non_private_post,
               foreign_key:  'post_id',
               foreign_type: 'Thredded::Post',
               class_name:   'Thredded::Post'
    belongs_to :private_post,
               foreign_key:  'post_id',
               foreign_type: 'Thredded::PrivatePost',
               class_name:   'Thredded::PrivatePost'
    validates :email, presence: true
    validates :post, presence: true
  end
end
