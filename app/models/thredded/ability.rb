module Thredded
  class Ability
    include ::CanCan::Ability

    def initialize(user)
      user ||= Thredded::NullUser.new
      user_details = Thredded::UserDetail.where(user_id: user.id).first

      can :manage, :all if user_details.try(:superadmin?)

      can :read, Thredded::Messageboard do |messageboard|
        Thredded::MessageboardUserPermissions.new(messageboard, user).readable?
      end

      can :manage, Thredded::Topic do |topic|
        Thredded::TopicUserPermissions.new(topic, user, user_details).manageable?
      end

      can :read, Thredded::Topic do |topic|
        Thredded::TopicUserPermissions.new(topic, user, user_details).readable?
      end

      can :create, Thredded::Topic do |topic|
        Thredded::TopicUserPermissions.new(topic, user, user_details).createable?
      end

      cannot :manage, Thredded::PrivateTopic

      can :manage, Thredded::PrivateTopic do |private_topic|
        Thredded::PrivateTopicUserPermissions.new(private_topic, user, user_details).manageable?
      end

      can :create, Thredded::PrivateTopic do |private_topic|
        Thredded::PrivateTopicUserPermissions.new(private_topic, user, user_details).createable?
      end

      can :read, Thredded::PrivateTopic do |private_topic|
        Thredded::PrivateTopicUserPermissions.new(private_topic, user, user_details).readable?
      end

      can :manage, Thredded::Post do |post|
        Thredded::PostUserPermissions.new(post, user, user_details).manageable?
      end
    end
  end
end
