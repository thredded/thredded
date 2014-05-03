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
      @user = params[:user]
      @messageboard = params[:messageboard]
    end

    def self.model_name
      Thredded::Topic.model_name
    end

    def categories
      topic.messageboard.categories
    end

    def category_options
      topic.messageboard.decorate.category_options
    end

    def filter
      topic.messageboard.filter
    end

    def save
      if valid?
        ActiveRecord::Base.transaction do
          topic.save!
          post.save!
        end
      end
    end

    def topic
      @topic ||= messageboard.topics.build(
        title: title,
        locked: locked,
        sticky: sticky,
        user: user,
        last_user: user,
        categories: topic_categories,
      )
    end

    def post
      @post ||= topic.posts.build(
        content: content,
        user: user,
        messageboard: messageboard,
        filter: messageboard.filter
      )
    end

    private

    def topic_categories
      if category_ids
        ids = category_ids.reject(&:empty?).map(&:to_i)
        Category.where(id: ids)
      else
        []
      end
    end

    def validate_children
      if topic.invalid?
        promote_errors(topic.errors)
      end

      if post.invalid?
        promote_errors(post.errors)
      end
    end

    def promote_errors(child_errors)
      child_errors.each do |attribute, message|
        errors.add(attribute, message)
      end
    end
  end
end
