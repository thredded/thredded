# frozen_string_literal: true

module Thredded
  # A view model for TopicCommon.
  class BaseTopicView
    delegate :title,
             :last_post_at,
             :created_at,
             :user,
             :last_user,
             :to_model,
             to: :@topic

    delegate :read?, :post_read?, :posts_count,
             to: :@read_state

    # @param [TopicCommon] topic
    # @param [UserTopicReadStateCommon, NullUserTopicReadState, nil] read_state
    # @param [#destroy?] policy
    def initialize(topic, read_state, policy)
      @topic = topic
      @read_state = read_state || Thredded::NullUserTopicReadState.new(posts_count: @topic.posts_count)
      @policy = policy
    end

    def states
      [@read_state.read? ? :read : :unread]
    end

    def can_update?
      @policy.update?
    end

    def can_destroy?
      @policy.destroy?
    end

    def path
      Thredded::UrlsHelper.topic_path(
        @topic,
        page: @read_state.first_unread_post_page || @read_state.last_read_post_page,
        anchor: ('unread' if @read_state.first_unread_post_page)
      )
    end
  end
end
