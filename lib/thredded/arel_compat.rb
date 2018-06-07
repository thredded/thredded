# frozen_string_literal: true

unless Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR >= 2 || Rails::VERSION::MAJOR > 5
  require 'thredded/rails_lt_5_2_arel_case_node.rb'
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

    if Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR >= 2 || Rails::VERSION::MAJOR > 5
      # @param [ActiveRecord::Relation] relation
      # @return [Arel::Nodes::Node]
      def relation_to_arel(relation)
        relation.arel
      end
    else
      def relation_to_arel(relation)
        Arel.sql("(#{relation.to_sql})")
      end
    end

    if Rails::VERSION::MAJOR >= 5
      # @param [Arel::Nodes::Node] table
      # @return [Arel::SelectManager]
      def new_arel_select_manager(table)
        Arel::SelectManager.new(table)
      end
    else
      def new_arel_select_manager(table)
        Arel::SelectManager.new(ActiveRecord::Base, table)
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
