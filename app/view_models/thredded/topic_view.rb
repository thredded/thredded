# frozen_string_literal: true
module Thredded
  # A view model for Topic.
  class TopicView < BaseTopicView
    delegate :categories, :id, :blocked?, :last_moderation_record, :followers,
             :last_post, :messageboard_id, :messageboard_name,
             to: :@topic

    # @param topic [TopicCommon]
    # @param read_state [UserTopicReadStateCommon, nil]
    # @param policy [#destroy?]
    def initialize(topic, read_state, follow, policy)
      super(topic, read_state, policy)
      @follow = follow
    end

    def self.from_user(topic, user)
      read_state = follow = nil
      if user && !user.thredded_anonymous?
        read_state = UserTopicReadState.find_by(user_id: user.id, postable_id: topic.id)
        follow = UserTopicFollow.find_by(user_id: user.id, topic_id: topic.id)
      end
      new(topic, read_state, follow, Pundit.policy!(user, topic))
    end

    def states
      super + [
        (:locked if @topic.locked?),
        (:sticky if @topic.sticky?),
        (@follow ? :following : :notfollowing)
      ].compact
    end

    # @return [Boolean] whether the topic is followed by the current user.
    def followed?
      @follow
    end

    def follow_reason
      @follow.try(:reason)
    end

    def can_moderate?
      @policy.moderate?
    end

    def edit_path
      Thredded::UrlsHelper.edit_messageboard_topic_path(@topic.messageboard, @topic)
    end

    def destroy_path
      Thredded::UrlsHelper.messageboard_topic_path(@topic.messageboard, @topic)
    end

    def follow_path
      Thredded::UrlsHelper.follow_messageboard_topic_path(@topic.messageboard, @topic)
    end

    def unfollow_path
      Thredded::UrlsHelper.unfollow_messageboard_topic_path(@topic.messageboard, @topic)
    end

    def messageboard_path
      Thredded::UrlsHelper.messageboard_topics_path(@topic.messageboard)
    end
  end
end
