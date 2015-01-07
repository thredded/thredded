module Thredded
  class PostSqlBuilder < TableSqlBuilder
    def build_text_search
      return if text.blank?

      add_from('thredded_posts p')
      add_where('t.id = p.postable_id')
      add_full_text_search('p.content', text)
    end

    def build_in_category
      return if categories.blank?

      add_from('thredded_topic_categories tc')
      add_where('tc.postable_id = t.id')
      add_where('tc.category_id in (?)', categories)
    end

    def build_by_user
      return if users.blank?

      add_from 'thredded_posts p'
      add_where('t.id = p.postable_id')
      add_where('p.user_id in (?)', users)
    end
  end
end
