module Thredded
  class PostDecorator < SimpleDelegator
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

    def original
      post
    end

    def avatar_url
      super.sub(/\Ahttp:/, '')
    end

    private

    def created_at_str
      created_at.getutc.to_s
    end

    def created_at_utc
      created_at.getutc.iso8601
    end
  end
end
