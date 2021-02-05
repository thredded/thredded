# frozen_string_literal: true

require 'thredded/rails_lt_5_2_arel_case_node.rb' unless Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR >= 2 || Rails::VERSION::MAJOR > 5

module Thredded
  module ArelCompat
    module_function

    # On Rails >= 5, this method simply returns `relation.pluck(*columns)`.
    #
    # Rails 4 `pluck` does not support Arel nodes and attributes. This method does.
    #
    # This is an external method because monkey-patching `pluck` would
    # have compatibility issues, see:
    #
    # https://github.com/thredded/thredded/issues/842
    # https://blog.newrelic.com/engineering/ruby-agent-module-prepend-alias-method-chains/
    if Rails::VERSION::MAJOR > 4
      def pluck(relation, *columns)
        relation.pluck(*columns)
      end
    else
      def pluck(relation, *columns)
        relation.pluck(*columns.map do |n|
          if n.is_a?(Arel::Node)
            Arel.sql(n.to_sql)
          elsif n.is_a?(Arel::Attributes::Attribute)
            n.name
          else
            n
          end
        end)
      end
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

    if Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR >= 2 || Rails::VERSION::MAJOR > 5
      def true_value(_engine)
        true
      end
    else
      def true_value(engine)
        engine.connection.adapter_name =~ /sqlite|mysql|mariadb/i ? 1 : true
      end
    end
  end
end
