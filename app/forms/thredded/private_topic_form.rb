module Thredded
  class PrivateTopicForm
    include ActiveModel::Model

    attr_accessor \
      :title,
      :category_ids,
      :user_ids,
      :locked,
      :sticky,
      :content,
      :private_topic

    attr_reader :user, :params

    validate :validate_children

    def initialize(params = {})
      @params = params
      @title = params[:title]
      @category_ids = params[:category_ids] || []
      @user_ids = params[:user_ids] || []
      @user = params[:user] || fail('user is required')
      @locked = params[:locked]
      @sticky = params[:sticky]
      @content = params[:content]
    end

    def self.model_name
      Thredded::PrivateTopic.model_name
    end

    def users
      @user.thredded_can_message_users
    end

    def users_for_select
      (users - [@user]).map { |user| [user.to_s, user.id] }
    end

    def id
      private_topic.id
    end

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        private_topic.save!
        post.save!
      end
      true
    end

    def private_topic
      @private_topic ||= Thredded::PrivateTopic.new(
        title: title,
        users: private_users,
        user: non_null_user,
        last_user: non_null_user)
    end

    def post
      @post ||= private_topic.posts.build(
        content: content,
        user: non_null_user)
    end

    def users_selected_options
      { selected: private_user_ids }
    end

    def users_select_html_options
      {
        multiple: true,
        required: true,
        'data-placeholder' => 'select users to participate in this topic',
        'data-thredded-users-select' => true
      }
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

    def private_users
      Thredded.user_class.where(id: normalized_user_ids)
    end

    def private_user_ids
      private_users.map(&:id)
    end

    def normalized_user_ids
      user_ids
        .reject(&:empty?)
        .map(&:to_i)
        .push(user.id)
        .uniq
    end

    # @return [Thredded.user_class, nil] return a user or nil if the user is a NullUser
    # This is necessary because assigning a NullUser to an ActiveRecord association results in an exception.
    def non_null_user
      @user unless @user.thredded_anonymous?
    end

    def validate_children
      promote_errors(private_topic.errors) if private_topic.invalid?
      promote_errors(post.errors) if post.invalid?
    end

    def promote_errors(child_errors)
      child_errors.each do |attribute, message|
        errors.add(attribute, message)
      end
    end
  end
end
