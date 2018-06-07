# frozen_string_literal: true

module Thredded
  class PrivatePostPolicy
    # The scope of readable private posts.
    # {PrivateTopicPolicy} must be applied separately.
    class Scope
      # @param user [Thredded.user_class]
      # @param scope [ActiveRecord::Relation<Thredded::Post>]
      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      # @return [ActiveRecord::Relation<Thredded::Post>]
      def resolve
        @scope
      end
    end

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
      !@post.first_post_in_topic? && update?
    end

    def anonymous?
      @user.thredded_anonymous?
    end

    private

    def own_post?
      @user.id == @post.user_id
    end
  end
end
