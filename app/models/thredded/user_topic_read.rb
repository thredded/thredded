module Thredded
  class UserTopicRead < ActiveRecord::Base
    attr_accessible :farthest_post,
      :page,
      :posts_count,
      :topic,
      :user

    belongs_to :topic
    belongs_to :user, class_name: Thredded.user_class
    belongs_to :farthest_post, class_name: 'Thredded::Post', foreign_key: 'post_id'
  end
end
