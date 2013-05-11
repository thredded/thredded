module Thredded
  class PostUserPermissions
    attr_reader :post, :user, :user_details, :messageboard, :topic

    def initialize(post, user, user_details)
      @post = post
      @topic = post.topic
      @messageboard = post.messageboard
      @user = user
      @user_details = user_details || UserDetail.new
    end

    def manageable?
      user.id == post.user_id
    end
  end
end


