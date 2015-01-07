require 'thredded/table_sql_builder'

module Thredded
  class TopicSqlBuilder < TableSqlBuilder
    def build_text_search
      return unless text.present?

      add_full_text_search('t.title', text)
    end

    def build_in_category
      return unless categories.present?

      add_from('topic_categories tc')
      add_where('tc.topic_id = t.id')
      add_where('tc.category_id in (?)', categories)
    end

    def build_by_user
      return unless users.present?

      add_where('t.user_id in (?)', users)
    end
  end
end
