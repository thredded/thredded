module Thredded
  class PostUserPermissions
    # @param post [Thredded::Post]
    # @param user [Thredded.user_class]
    def initialize(post, user)
      @post = post
      @user = user
    end

    def editable?
      own_post? || messageboard_user_permissions.moderatable?
    end

    def creatable?
      !@post.postable.locked? && messageboard_user_permissions.postable?
    end

    private

    def messageboard_user_permissions
      @messageboard_user_permission ||= MessageboardUserPermissions.new(@post.messageboard, @user)
    end

    def own_post?
      @user.id == @post.user_id
    end
  end
end
