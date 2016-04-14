# frozen_string_literal: true
module Thredded
  class PrivatePostUserPermissions
    # @param post [Thredded::PrivatePost]
    # @param user [Thredded.user_class]
    def initialize(post, user)
      @post = post
      @user = user
    end

    def editable?
      own_post?
    end

    def manageable?
      own_post?
    end

    def creatable?
      @post.postable.users.include?(@user)
    end

    private

    def own_post?
      @user.id == @post.user_id
    end
  end
end
