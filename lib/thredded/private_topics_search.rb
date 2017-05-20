# frozen_string_literal: true
require_dependency 'thredded/search_parser'
module Thredded
  class PrivateTopicsSearch
    def initialize(query, scope)
      @terms = SearchParser.new(query).parse
      @scope = scope

      @search_text = nil
    end

    # @return [ActiveRecord::Relation<Thredded::Topic>]
    def search
      if text.present?
        [search_topics, search_posts].compact.reduce(:union)
      else
        @scope
      end
    end

    protected

    def search_topics
      scope = @scope
      scope = DbTextSearch::FullText.new(scope, :title).search(text) if text.present?
      scope
    end

    def search_posts
      posts_scope = Thredded::PrivatePost
      posts_scope = DbTextSearch::FullText.new(posts_scope, :content).search(text) if text.present?
      @scope.joins(:posts).merge(posts_scope)
    end

    # @return [Array<String>]
    def text
      @terms['text']
    end
  end
end
