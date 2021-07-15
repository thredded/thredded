# frozen_string_literal: true

module Thredded
  module ArelCompat
    module_function

    # @param [#connection] engine
    # @param [Arel::Nodes::Node] a integer node
    # @param [Arel::Nodes::Node] b integer node
    # @return [Arel::Nodes::Node] a / b
    def integer_division(engine, a, b)
      if engine.connection.adapter_name =~ /mysql|mariadb/i
        Arel::Nodes::InfixOperation.new('DIV', a, b)
      else
        Arel::Nodes::Division.new(a, b)
      end
    end

    def true_value(_engine)
      true
    end
  end
end
