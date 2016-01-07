require 'thredded/base_user_topic_decorator'

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
      if user.id > 0
        @read_status ||= topic.user_topic_reads.select do |reads|
          reads.user_id == user.id
        end
      end

      if @read_status.blank?
        Thredded::NullTopicRead.new
      else
        @read_status.first
      end
    end
  end
end
