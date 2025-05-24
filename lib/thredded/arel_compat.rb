# frozen_string_literal: true

module Thredded
  module ArelCompat
    module_function

    # @param [#connection] engine
    # @param [Arel::Nodes::Node] a integer node
    # @param [Arel::Nodes::Node] b integer node
    # @return [Arel::Nodes::Node] a / b
    def integer_division(engine, a, b)
      if /mysql|mariadb/i.match?(engine.connection.adapter_name)
        Arel::Nodes::InfixOperation.new('DIV', a, b)
      else
        Arel::Nodes::Division.new(a, b)
      end
    end

    # @param [#connection] engine_or_model_class
    # @param [Arel::Nodes::Node] left
    # @param [Arel::Nodes::Node] right
    # @return [Arel::Nodes::Node] union of left and right
    # extract and simplified from https://github.com/brianhempel/active_record_union/blob/master/lib/active_record_union/active_record/relation/union.rb
    def union_new(engine_or_model_class, left, right)
      if /sqlite/i.match?(engine_or_model_class.connection.adapter_name)
        # Postgres allows ORDER BY in the UNION subqueries if each subquery is surrounded by parenthesis
        # but SQLite does not allow parens around the subqueries
        Arel::Nodes::Union.new(left.ast, right.ast)
      else
        # By default this adds parentheses which sqlite does not allow
        Arel::Nodes::Union.new(left, right)
      end
    end
  end
end
