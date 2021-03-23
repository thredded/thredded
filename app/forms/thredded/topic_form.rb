# frozen_string_literal: true

module Thredded
  class TopicForm
    include ActiveModel::Model

    attr_accessor :title, :category_ids, :locked, :sticky, :content, :video_url, :badge_id
    attr_reader :user, :messageboard, :id, :post_views, :type

    validate :validate_children

    def initialize(params = {})
      @title = params[:title]
      @category_ids = params[:category_ids]
      @locked = params[:locked] || false
      @sticky = params[:sticky] || false
      @content = params[:content]
      @user = params[:user] || fail('user is required')
      @messageboard = params[:messageboard]
      @type = params[:type]
      @badge_id = params[:badge_id]
      @video_url = params[:video_url]
    end

    def self.model_name
      Thredded::Topic.model_name
    end

    def category_options
      messageboard.categories.map { |cat| [cat.name, cat.id] }
    end

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        new_topic = !topic.persisted?
        topic.save!
        post.save!
        Thredded::UserTopicReadState.read_on_first_post!(user, post) if new_topic
      end
      true
    end

    def topic
      topic_params = {title: title,
                      locked: locked,
                      sticky: sticky,
                      user: non_null_user,
                      category_ids: category_ids,
                      type: type,
                      video_url: video_url}

      if badge_id && user.thredded_admin?
        Thredded::Badge.find!(badge_id)
        topic_params[:badge_id] = badge_id
      end

      @topic ||= messageboard.topics.build(topic_params)
    end

    def post
      @post ||= topic.posts.build(
        content: content,
        user: non_null_user,
        messageboard: messageboard
      )
    end

    def submit_path
      Thredded::UrlsHelper.url_for([messageboard, topic, only_path: true])
    end

    def preview_path
      Thredded::UrlsHelper.preview_new_messageboard_topic_path(messageboard)
    end

    private

    # @return [Thredded.user_class, nil] return a user or nil if the user is a NullUser
    # This is necessary because assigning a NullUser to an ActiveRecord association results in an exception.
    def non_null_user
      @user unless @user.thredded_anonymous?
    end

    def topic_categories
      if category_ids
        ids = category_ids.reject(&:empty?)
        Thredded::Category.where(id: ids)
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
