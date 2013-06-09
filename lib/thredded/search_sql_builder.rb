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
        'SELECT * FROM topics WHERE id IN (', @post_builder.sql,
        'UNION', @topic_builder.sql,
        ')', @order_by,
        'LIMIT 50'
      ].join(' ')
    end

    def binds
      @post_builder.binds.concat(@topic_builder.binds)
    end
  end
end
