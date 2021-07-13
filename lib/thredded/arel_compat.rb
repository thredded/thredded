# frozen_string_literal: true

module Thredded
  module ArelCompat
    module_function

    # TODO: inline this method (just use relation.pluck)
    # On Rails >= 5, this method simply returns `relation.pluck(*columns)`.
    #
    # Rails 4 `pluck` does not support Arel nodes and attributes. This method does.
    #
    # This is an external method because monkey-patching `pluck` would
    # have compatibility issues, see:
    #
    # https://github.com/thredded/thredded/issues/842
    # https://blog.newrelic.com/engineering/ruby-agent-module-prepend-alias-method-chains/
    def pluck(relation, *columns)
      relation.pluck(*columns)
    end

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
