# frozen_string_literal: true
module Thredded
  # A view model for Topic.
  class TopicView < BaseTopicView
    delegate :categories, :id,
             to: :@topic

    def states
      super + [
        (:locked if @topic.locked?),
        (:sticky if @topic.sticky?),
      ].compact
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
  end
end
