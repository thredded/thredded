# frozen_string_literal: true

module Thredded
  class EditTopicForm
    include ActiveModel::Model

    delegate :id, :title, :title_was, :category_ids, :locked, :sticky, :messageboard, :messageboard_id, :valid?,
             :errors,
             to: :@topic

    # @param user [Thredded.user_class]
    # @param topic [Thredded::Topic]
    def initialize(user:, topic:)
      @user = user
      @topic = topic
    end

    def self.model_name
      Thredded::Topic.model_name
    end

    def category_options
      @topic.messageboard.categories.map { |cat| [cat.name, cat.id] }
    end

    def messageboard_options
      @user.thredded_can_write_messageboards.map { |messageboard| [messageboard.name, messageboard.id] }
    end

    def save
      return false unless valid?
      @topic.save!
      true
    end

    def persisted?
      true
    end

    def path
      Thredded::UrlsHelper.messageboard_topic_path(@topic.messageboard, @topic)
    end

    def edit_path
      Thredded::UrlsHelper.edit_messageboard_topic_path(@topic.messageboard, @topic)
    end

    def messageboard_path
      Thredded::UrlsHelper.messageboard_topics_path(@topic.messageboard)
    end
  end
end
