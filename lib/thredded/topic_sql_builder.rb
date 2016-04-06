require 'thredded/table_sql_builder'

module Thredded
  class TopicSqlBuilder < TableSqlBuilder
    def apply_filters
      @scope = @scope.joins(:topic_categories).where(category_id: categories) if categories.present?
      @scope = @scope.where(user_id: users) if users.present?
      @scope = DbTextSearch::FullText.new(@scope, :title).search(text) if text.present?
    end
  end
end
