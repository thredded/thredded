# frozen_string_literal: true

unless Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR >= 2 || Rails::VERSION::MAJOR > 5
  require 'thredded/rails_lt_5_2_arel_case_node.rb'
end

if Rails::VERSION::MAJOR == 4
  # Make `pluck` compatible with Arel.
  require 'active_record/relation'
  ActiveRecord::Relation.prepend(Module.new do
    def pluck(*column_names)
      super(*column_names.map do |n|
        if n.is_a?(Arel::Node)
          Arel.sql(n.to_sql)
        elsif n.is_a?(Arel::Attributes::Attribute)
          n.name
        else
          n
        end
      end)
    end
  end)
end

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
  end
end
