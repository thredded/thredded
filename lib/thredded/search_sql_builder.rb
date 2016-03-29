require 'thredded/topic_sql_builder'
require 'thredded/post_sql_builder'

module Thredded
  class SearchSqlBuilder
    def initialize(query, messageboard)
      @topic_builder = TopicSqlBuilder.new(query, messageboard)
      @post_builder = PostSqlBuilder.new(query, messageboard)
      @order_by = 'ORDER BY updated_at DESC'
    end

    def build
      [
        'SELECT * FROM thredded_topics WHERE id IN (', @post_builder.sql,
        'UNION', @topic_builder.sql,
        ')', @order_by,
        'LIMIT 50'
      ].join(' ')
    end
  end
end
