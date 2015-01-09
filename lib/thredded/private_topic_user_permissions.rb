module Thredded
  class PrivateTopicUserPermissions
    attr_reader :private_topic, :user, :user_details, :messageboard

    def initialize(private_topic, user, user_details)
      @private_topic = private_topic
      @messageboard = private_topic.messageboard
      @user = user
      @user_details = user_details || UserDetail.new
    end

    def listable?
      return unless user.thredded_private_topics

      user.thredded_private_topics.for_user(user).any?
    end

    def manageable?
      user_started_topic?
    end

    def readable?
      private_topic.users.include?(user)
    end

    def creatable?
      TopicUserPermissions.new(private_topic, user, user_details).creatable?
    end

    private

    def user_started_topic?
      user.id == private_topic.user_id
    end
  end
end
