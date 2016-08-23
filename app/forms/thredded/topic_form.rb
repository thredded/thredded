# frozen_string_literal: true
module Thredded
  class TopicForm
    include ActiveModel::Model

    attr_accessor :title, :category_ids, :locked, :sticky, :content, :topic
    attr_reader :user, :messageboard

    validate :validate_children

    def initialize(params = {})
      @title = params[:title]
      @category_ids = params[:category_ids]
      @locked = params[:locked] || false
      @sticky = params[:sticky] || false
      @content = params[:content]
      @user = params[:user] || fail('user is required')
      @messageboard = params[:messageboard]
    end

    def self.model_name
      Thredded::Topic.model_name
    end

    def categories
      topic.messageboard.categories
    end

    def category_options
      categories.map { |cat| [cat.name, cat.id] }
    end

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        topic.save!
        post.save!
        UserTopicReadState.read_on_first_post!(user, topic) if topic.previous_changes.include?(:id)
      end
      true
    end

    def topic
      @topic ||= messageboard.topics.build(
        title: title,
        locked: locked,
        sticky: sticky,
        user: non_null_user,
        categories: topic_categories,
      )
    end

    def post
      @post ||= topic.posts.build(
        content: content,
        user: non_null_user,
        messageboard: messageboard
      )
    end

    private

    # @return [Thredded.user_class, nil] return a user or nil if the user is a NullUser
    # This is necessary because assigning a NullUser to an ActiveRecord association results in an exception.
    def non_null_user
      @user unless @user.thredded_anonymous?
    end

    def topic_categories
      if category_ids
        ids = category_ids.reject(&:empty?).map(&:to_i)
        Category.where(id: ids)
      else
        []
      end
    end

    def validate_children
      promote_errors(topic.errors) if topic.invalid?
      promote_errors(post.errors) if post.invalid?
    end

    def promote_errors(child_errors)
      child_errors.each do |attribute, message|
        errors.add(attribute, message)
      end
    end
  end
end
