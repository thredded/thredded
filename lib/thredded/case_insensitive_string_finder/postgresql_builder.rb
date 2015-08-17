module Thredded
  class CaseInsensitiveStringFinder
    module PostgreSQLBuilder
      # @param [String, Array<String>] values
      # @return [ActiveRecord::Relation]
      def find(values)
        conn = scope.connection
        if values.blank?
          scope.none
        else
          scope.where(<<-SQL.strip_heredoc)
          LOWER(#{conn.quote_table_name(scope.table_name)}.#{conn.quote_column_name(column)})
            IN (#{Array(values).map { |v| "LOWER(#{conn.quote(v.to_s)})" }.join(', ')})
          SQL
        end
      end
    end
  end
end
