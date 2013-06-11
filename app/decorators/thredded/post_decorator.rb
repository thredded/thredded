module Thredded
  class PostDecorator < SimpleDelegator
    attr_reader :post

    def initialize(post)
      super
      @post = post
    end

    def avatar
      'avatar'
    end

    def user_partial
      if post.user.valid?
        'thredded/posts/user'
      else
        'thredded/posts/null_user'
      end
    end

    def user_roles
      Role
        .where(user_id: post.user.id)
        .for(post.messageboard)
        .pluck(:level)
        .to_sentence
    end

    def user_posts_count
      0
    end

    def created_timestamp
      'timestamp'
    end

    def created_date
      'date'
    end
  end
end
