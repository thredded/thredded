module Thredded
  class Ability
    include ::CanCan::Ability

    def initialize(user)
      user ||= Thredded::NullUser.new

      can :manage, :all if user.superadmin?

      can :read, Site, permission: 'public'

      can :read, Site do |site|
        site.permission == 'logged_in' && user.valid?
      end

      can :read, Messageboard do |messageboard|
        user.can_read_messageboard?(messageboard)
      end

      can :manage, Topic do |topic|
        user.admins?(topic.messageboard) || topic.user == user
      end

      can :read, Topic do |topic|
        user.can_read_messageboard?(topic.messageboard)
      end

      can :create, Topic do |topic|
        user.member_of?(topic.messageboard)
      end

      can :create, Topic do |topic|
        messageboard = topic.messageboard
        messageboard_permissions = messageboard.restricted_to_logged_in? ||
          messageboard.posting_for_logged_in?
        messageboard_permissions && user.valid?
      end

      cannot :manage, PrivateTopic

      can :manage, PrivateTopic, user_id: user.id

      can :create, PrivateTopic do |private_topic|
        user.member_of?(private_topic.messageboard)
      end

      can :read, PrivateTopic do |private_topic|
        private_topic.users.include?(user)
      end

      can :manage, Post do |post|
        user.admins?(post.topic.messageboard) || post.user == user
      end
    end
  end
end
