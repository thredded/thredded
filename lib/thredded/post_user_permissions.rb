module Thredded
  class PostUserPermissions
    attr_reader :post, :user, :user_details, :messageboard, :topic

    def initialize(post, user, user_details)
      @post = post
      @topic = post.postable
      @messageboard = post.messageboard
      @user = user
      @user_details = user_details || UserDetail.new
    end

    def editable?
      created_post? || messageboard.member_is_a?(user, 'admin')
    end

    def manageable?
      created_post?
    end

    def creatable?
      thread_is_not_locked? && can_create_topic?
    end

    private

    def created_post?
      user.id == post.user_id
    end

    def thread_is_not_locked?
      @topic.private? || @topic.public? && !@topic.locked?
    end

    def can_create_topic?
      TopicUserPermissions.new(@topic, @user, @user_details).creatable?
    end
  end
end
