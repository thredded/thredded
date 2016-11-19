# frozen_string_literal: true
module Thredded
  class PrivatePostPolicy
    # @param user [Thredded.user_class]
    # @param post [Thredded::PrivatePost]
    def initialize(user, post)
      @user = user
      @post = post
    end

    def create?
      @user.thredded_admin? || @post.postable.users.include?(@user) && !@user.thredded_user_detail.blocked?
    end

    def read?
      Thredded::PrivateTopicPolicy.new(@user, @post.postable).read?
    end

    def update?
      @user.thredded_admin? || own_post?
    end

    def destroy?
      @post.postable.first_post != @post && update?
    end

    private

    def own_post?
      @user.id == @post.user_id
    end
  end
end
