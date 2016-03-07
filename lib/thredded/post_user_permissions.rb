module Thredded
  class PostUserPermissions
    def initialize(post, user, _user_details)
      @post                         = post
      @topic                        = post.postable
      @messageboard_user_permission = MessageboardUserPermissions.new(post.messageboard, user)
      @user                         = user
    end

    def editable?
      created_post? || @messageboard_user_permission.moderatable?
    end

    def manageable?
      created_post? || @messageboard_user_permission.moderatable?
    end

    def creatable?
      thread_is_not_locked? && @messageboard_user_permission.postable?
    end

    private

    def created_post?
      @user.id == @post.user_id
    end

    def thread_is_not_locked?
      @topic.private? || !@topic.locked?
    end
  end
end
