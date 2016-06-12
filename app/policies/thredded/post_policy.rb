# frozen_string_literal: true
require_dependency 'thredded/topic_policy'
module Thredded
  class PostPolicy
    # The scope of readable posts.
    # MessageboardPolicy must be applied separately.
    class Scope
      # @param user [Thredded.user_class]
      # @param scope [ActiveRecord::Relation<Thredded::Post>]
      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      # @return [ActiveRecord::Relation<Thredded::Post>]
      def resolve
        @scope.moderation_state_visible_to_user(@user)
      end
    end

    # @param user [Thredded.user_class]
    # @param post [Thredded::Post]
    def initialize(user, post)
      @user = user
      @post = post
    end

    def create?
      @user.thredded_admin? || !@post.postable.locked? && messageboard_policy.post?
    end

    def read?
      TopicPolicy.new(@user, @post.postable).read? && @post.moderation_state_visible_to_user?(@user)
    end

    def update?
      @user.thredded_admin? || own_post? || messageboard_policy.moderate?
    end

    def destroy?
      @post.postable.first_post != @post && update?
    end

    delegate :moderate?, to: :messageboard_policy

    private

    def messageboard_policy
      @messageboard_policy ||= MessageboardPolicy.new(@user, @post.messageboard)
    end

    def own_post?
      @user.id == @post.user_id
    end
  end
end
