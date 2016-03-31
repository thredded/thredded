require 'thredded/search_parser'
module Thredded
  class TableSqlBuilder
    def initialize(query, messageboard)
      @terms = SearchParser.new(query).parse
      @scope = Thredded::Topic.select(:id).where(messageboard_id: messageboard.id)
      @search_categories = @search_users = @search_text = nil
    end

    def sql
      apply_filters
      @scope.to_sql
    end

    protected

    def categories
      @search_categories ||=
        if @terms['in']
          DbTextSearch::CaseInsensitiveEq.new(Category, :name)
            .find(@terms['in']).pluck(:id)
        else
          []
        end
    end

    def users
      @search_users ||=
        if @terms['by']
          DbTextSearch::CaseInsensitiveEq.new(Thredded.user_class, Thredded.user_name_column)
            .find(@terms['by']).pluck(:id)
        else
          []
        end
    end

    def text
      @terms['text']
    end
  end
end
