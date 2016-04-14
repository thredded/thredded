# frozen_string_literal: true
module Thredded
  class UserTopicDecorator < BaseUserTopicDecorator
    def self.topic_class
      Topic
    end

    def farthest_page
      read_status.page
    end

    def farthest_post
      read_status.farthest_post
    end

    def read?
      topic.posts_count == read_status.posts_count
    end

    private

    def read_status
      # TODO: Avoid loading read status for *all* the users.
      @read_status ||= topic.user_topic_reads.find { |reads| reads.user_id == user.id } || Thredded::NullTopicRead.new
    end
  end
end
