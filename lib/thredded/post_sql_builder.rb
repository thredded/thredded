module Thredded
  class PostSqlBuilder < TableSqlBuilder
    def apply_filters
      @scope = @scope.joins(:topic_categories).where(category_id: categories) if categories.present?
      return unless users.present? || text.present?
      posts_scope = Thredded::Post
      posts_scope = posts_scope.where(user_id: users) if users.present?
      posts_scope = DbTextSearch::FullTextSearch.new(posts_scope, :content).find(text) if text.present?
      @scope      = @scope.joins(:posts).merge(posts_scope)
    end
  end
end
