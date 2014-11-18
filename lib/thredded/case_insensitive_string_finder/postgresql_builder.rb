module Thredded
  class CaseInsensitiveStringFinder
    module PostgreSQLBuilder
      # @param [String, Array<String>] values
      # @return [ActiveRecord::Relation]
      def find(values)
        scope.where("lower(#{column}) IN (?)", Array(values).map(&:downcase))
      end
    end
  end
end
