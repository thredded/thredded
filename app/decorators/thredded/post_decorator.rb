# frozen_string_literal: true
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

    def to_ary
      [self]
    end
  end
end
