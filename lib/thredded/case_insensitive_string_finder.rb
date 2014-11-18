module Thredded
  # Exact case-insensitive string matching
  class CaseInsensitiveStringFinder
    # @return [Class<ActiveRecord::Base, ActiveRecord::Relation>]
    attr_reader :scope
    # @return [Symbol]
    attr_reader :column

    # @param [Class<ActiveRecord::Base, ActiveRecord::Relation>] scope
    # @param [Symbol] column
    def initialize(scope, column)
      @scope  = scope
      @column = column
    end

    def self.use_adapter!(db_adapter)
      case db_adapter
        when /mysql/
          require 'thredded/case_insensitive_string_finder/mysql_builder'
          include MySQLBuilder
        when /postgresql/
          require 'thredded/case_insensitive_string_finder/postgresql_builder'
          include PostgreSQLBuilder
        else
          fail "Please define CaseInsensitiveStringFinder for #{db_adapter}"
      end
    end
  end
end
