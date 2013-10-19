module Thredded
  class NullTopicRead
    def page
      1
    end

    def post_id
      0
    end

    def posts_count
      0
    end

    def farthest_post
      Post.new
    end
  end
end
