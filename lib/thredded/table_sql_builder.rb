require 'thredded/search_parser'
module Thredded
  class TableSqlBuilder
    attr_accessor :binds

    def initialize(query, messageboard)
      @terms = SearchParser.new(query).parse

      @select = 'SELECT t.id'
      @from   = 'FROM thredded_topics t'
      @where  = ['t.messageboard_id = ?']
      @binds  = [messageboard.id]

      @search_categories = []
      @search_users      = []
      @search_text       = []
    end

    def sql
      build_by_user
      build_in_category
      build_text_search

      [@select,
       @from,
       'WHERE', @where.join(' AND '),
      ].join(' ')
    end

    private

    def quoted?(term)
      term.count('"') == 2
    end

    def categories
      if @search_categories.any?
        @search_categories
      else
        if @terms['in']
          @search_categories.concat CaseInsensitiveStringFinder.new(Category, :name).find(@terms['in']).pluck(:id)
        end
        @search_categories
      end
    end

    def users
      if @search_users.any?
        @search_users
      else
        if @terms['by']
          @search_user.concat CaseInsensitiveStringFinder.new(Thredded.user_class, Thredded.user_name_column).find(@terms['by']).pluck(:id)
        end
        @search_users
      end
    end

    def text
      @terms['text']
    end

    def build_by_user
      raise 'SubclassResponsibility'
    end

    def build_in_category
      raise 'SubclassResponsibility'
    end

    def build_text_search
      raise 'SubclassResponsibility'
    end

    def add_from(table)
      if @from.exclude? table
        @from = "#{@from}, #{table}"
      end
    end

    def add_where(where, binds=nil)
      if @where.exclude? where
        @where << where
        if binds.present?
          @binds.push(binds)
        end
      end
    end

    def self.use_adapter!(db_adapter)
      case db_adapter
        when /mysql/
          require 'thredded/full_text_search/mysql_builder'
          include FullTextSearch::MySQLBuilder
        when /postgresql/
          require 'thredded/full_text_search/postgresql_builder'
          include FullTextSearch::PostgreSQLBuilder
        else
          Rails.logger.warn "No FullTextSearch adapter defined for #{db_adapter}"
          Thredded.define_singleton_method :supports_fulltext_search? do
            false
          end
      end
    end
  end
end
