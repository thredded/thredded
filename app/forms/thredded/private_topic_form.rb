# frozen_string_literal: true

module Thredded
  class PrivateTopicForm # rubocop:disable Metrics/ClassLength
    include ActiveModel::Model

    delegate :id,
             :title_was,
             to: :private_topic

    attr_accessor \
      :title,
      :category_ids,
      :user_ids,
      :locked,
      :sticky,
      :content

    attr_reader :user, :params
    attr_writer :user_names

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
      @user_names = params[:user_names]
    end

    def self.model_name
      Thredded::PrivateTopic.model_name
    end

    def save
      @user_ids ||= []
      @user_ids += Thredded.user_class.where(Thredded.user_name_column => parse_names(user_names)).pluck(:id)

      return false unless valid?

      ActiveRecord::Base.transaction do
        new_topic = !private_topic.persisted?
        private_topic.save!
        post.save!
        Thredded::UserPrivateTopicReadState.read_on_first_post!(user, post) if new_topic
      end
      true
    end

    def private_topic
      @private_topic ||= Thredded::PrivateTopic.new(
        title: title,
        users: private_users,
        user: non_null_user,
        last_user: non_null_user
      )
    end

    def post
      @post ||= private_topic.posts.build(
        content: content,
        user: non_null_user
      )
    end

    def submit_path
      Thredded::UrlsHelper.url_for([private_topic, only_path: true])
    end

    def preview_path
      Thredded::UrlsHelper.preview_new_private_topic_path
    end

    def user_names
      @user_names ||= Thredded.user_class.where(id: user_ids).pluck(Thredded.user_name_column).map do |name|
        if name.include?(',')
          "\"#{name}\""
        else
          name
        end
      end.join(', ')
    end

    private

    def topic_categories
      if category_ids
        ids = category_ids.reject(&:empty?)
        Thredded::Category.where(id: ids)
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
        .map(&:to_s)
        .reject(&:empty?)
        .push(user.id.to_s)
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

    def parse_names(text) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
      result = []
      current = +''
      in_name = in_quoted = false
      text.each_char do |char|
        case char
        when '"'
          in_quoted = !in_quoted
        when ' '
          current << char if in_name
        when ','
          if in_quoted
            current << char
          else
            in_name = false
            unless current.empty?
              result << current.dup
              current.clear
            end
          end
        else
          in_name = true
          current << char
        end
      end
      result << current unless current.empty?
      result
    end
  end
end
