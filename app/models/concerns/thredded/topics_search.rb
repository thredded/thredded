# frozen_string_literal: true

module Thredded
  class TopicsSearch
    def initialize(query, scope)
      @terms = Thredded::SearchParser.new(query).parse
      @scope = scope

      @search_categories = @search_users = @search_text = nil
    end

    # @return [ActiveRecord::Relation<Thredded::Topic>]
    def search
      if categories.present?
        @scope = @scope.joins(:topic_categories).merge(Thredded::TopicCategory.where(category_id: categories))
      end
      if text.present? || users.present?
        [search_topics, search_posts].compact.reduce(:union)
      else
        @scope
      end
    end

    protected

    def search_topics
      scope = @scope
      scope = @scope.where(user_id: users) if users.present?
      scope = DbTextSearch::FullText.new(scope, :title).search(text) if text.present?
      scope
    end

    def search_posts
      posts_scope = Thredded::Post
      posts_scope = posts_scope.where(user_id: users) if users.present?
      posts_scope = DbTextSearch::FullText.new(posts_scope, :content).search(text) if text.present?
      @scope.joins(:posts).merge(posts_scope)
    end

    def categories
      @search_categories ||=
        if @terms['in'].present?
          DbTextSearch::CaseInsensitive
            .new(Category, :name)
            .in(@terms['in']).pluck(:id)
        else
          []
        end
    end

    def users
      @search_users ||=
        if @terms['by']
          DbTextSearch::CaseInsensitive
            .new(Thredded.user_class, Thredded.user_name_column)
            .in(@terms['by']).pluck(:id)
        else
          []
        end
    end

    # @return [Array<String>]
    def text
      @terms['text']
    end
  end
end
