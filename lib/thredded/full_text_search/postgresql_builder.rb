module Thredded
  module FullTextSearch
    module PostgreSQLBuilder
      def add_full_text_search(column, terms)
        add_where("to_tsvector('english', #{column}) @@ plainto_tsquery('english', ?)", terms.uniq.join(' '))
        terms.each do |term|
          add_where("#{column} ILIKE ?", term.tr('"', '%')) if quoted?(term)
        end
      end
    end
  end

  def self.supports_fulltext_search?
    true
  end
end
