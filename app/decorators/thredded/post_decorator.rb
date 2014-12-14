module Thredded
  class PostDecorator < SimpleDelegator
    include Thredded::HtmlDecorator
    attr_reader :post

    def initialize(post)
      super
      @post = post
    end

    def user_name
      if user
        user.to_s
      else
        'Anonymous'
      end
    end

    def user_link
      if post.user
        link_to post.user.to_s, user_path(post.user)
      else
        '<a href="#">?</a>'.html_safe
      end
    end

    def original
      post
    end

    def created_at_timeago
      timeago_tag created_at, class: 'created_at'
    end

    def avatar_url
      super.sub(/\Ahttp:/, '')
    end
  end
end
