module Thredded
  class PostSqlBuilder < TableSqlBuilder
    def build_text_search
      if text.present?
        search_text = text
        add_from('thredded_posts p')
        add_where('t.id = p.postable_id')
        add_where("to_tsvector('english', p.content) @@ plainto_tsquery('english', ?)", search_text.uniq.join(' '))

        search_text.each do |term|
          if (is_quoted(term))
            add_where('p.content ILIKE ?', term.gsub('"', '%'))
          end
        end
      end
    end

    def build_in_category
      if categories.present?
        add_from('thredded_topic_categories tc')
        add_where('tc.postable_id = t.id')
        add_where('tc.category_id in (?)', categories)
      end
    end

    def build_by_user
      if users.present?
        add_from 'thredded_posts p'
        add_where('t.id = p.postable_id')
        add_where('p.user_id in (?)', users)
      end
    end
  end
end
