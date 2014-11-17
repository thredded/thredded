module Thredded
  class CaseInsensitiveStringFinder
    module MySQLBuilder
      # @param [String, Array<String>] values
      # @return [ActiveRecord::Relation]
      def find(values)
        scope.where(column => values)
      end
    end
  end
end
