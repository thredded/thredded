module Thredded
  module FullTextSearch
    module MySQLBuilder
      def add_full_text_search(column, terms)
        add_where("MATCH (#{column.sub(/\A\w\./, '')}) AGAINST (?)", terms.uniq.join(' '))
      end
    end
  end

  def self.supports_fulltext_search?
    return @supports_fulltext_search unless @supports_fulltext_search.nil?
    version                   = ActiveRecord::Base.connection.select_value('SELECT version()')
    @supports_fulltext_search = ([5, 6, 4] <=> version.split('.').map(&:to_i)) <= 0
    unless @supports_fulltext_search
      Rails.logger.warn 'Thredded requires MySQL v5.6.4+ for full text search support'
    end
    @supports_fulltext_search
  end
end
