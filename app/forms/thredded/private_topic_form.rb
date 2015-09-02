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

    attr_reader :user, :messageboard, :params

    validate :validate_children

    def initialize(params = {})
      @params = params
      @title = params[:title]
      @category_ids = params[:category_ids] || []
      @user_ids = params[:user_ids] || []
      @user = params[:user] || Thredded.user_class.new
      @locked = params[:locked] || false
      @sticky = params[:sticky] || false
      @content = params[:content]
      @messageboard = params[:messageboard]
    end

    def self.model_name
      Thredded::PrivateTopic.model_name
    end

    def categories
      messageboard.categories
    end

    def category_options
      messageboard.decorate.category_options
    end

    def filter
      messageboard.filter
    end

    def users
      messageboard.users
    end

    def id
      private_topic.id
    end

    def save
      return unless valid?

      ActiveRecord::Base.transaction do
        private_topic.save!
        post.save!
      end
    end

    def private_topic
      @private_topic ||= messageboard.private_topics.build(
        title: title,
        users: private_users,
        user: user,
        last_user: user,
      )
    end

    def post
      @post ||= private_topic.posts.build(
        content: content,
        user: user,
        messageboard: messageboard,
        filter: messageboard.filter
      )
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

    def users_options
      messageboard.decorate.users_options
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
