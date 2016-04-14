# frozen_string_literal: true
module Thredded
  class Ability
    include ::CanCan::Ability

    def initialize(user)
      user ||= Thredded::NullUser.new

      can :manage, :all if user.thredded_admin?

      can :read, Thredded::Messageboard do |messageboard|
        Thredded::MessageboardUserPermissions.new(messageboard, user).readable?
      end

      can [:moderate, :destroy], Thredded::Topic do |topic|
        Thredded::TopicUserPermissions.new(topic, user).moderatable?
      end

      [[Thredded::Topic, Thredded::TopicUserPermissions],
       [Thredded::PrivateTopic, Thredded::PrivateTopicUserPermissions]].each do |(topic_class, permissions_class)|
        can [:edit, :update], topic_class do |private_topic|
          permissions_class.new(private_topic, user).editable?
        end

        can :create, topic_class do |private_topic|
          permissions_class.new(private_topic, user).creatable?
        end

        can :read, topic_class do |private_topic|
          permissions_class.new(private_topic, user).readable?
        end
      end

      [[Thredded::Post, Thredded::PostUserPermissions],
       [Thredded::PrivatePost, Thredded::PrivatePostUserPermissions]].each do |(post_class, permissions_class)|
        can [:edit, :update, :destroy], post_class do |post|
          # Cancan calls this even for admin users, although it ignores the result.
          # Avoid unnecessary checks: https://github.com/CanCanCommunity/cancancan/issues/313
          post_class == Thredded::Post && user.thredded_admin? ||
            permissions_class.new(post, user).editable?
        end

        can :create, post_class do |post|
          permissions_class.new(post, user).creatable?
        end

        # Use cannot to override admin permissions. Even admin cannot destroy the first post of a topic.
        cannot :destroy, post_class do |post|
          post.postable.first_post == post
        end
      end
    end
  end
end
