# frozen_string_literal: true

module Arel
  module Nodes
    class Case < Arel::Nodes::Node
      include Arel::OrderPredications
      include Arel::Predications
      include Arel::AliasPredication

      attr_accessor :case, :conditions, :default

      def initialize(expression = nil, default = nil)
        @case = expression
        @conditions = []
        @default = default
      end

      def when(condition, expression = nil)
        @conditions << When.new(Nodes.build_quoted(condition), expression)
        self
      end

      def then(expression)
        @conditions.last.right = Nodes.build_quoted(expression)
        self
      end

      def else(expression)
        @default = Else.new Nodes.build_quoted(expression)
        self
      end

      def initialize_copy(other)
        super
        @case = @case.clone if @case
        @conditions = @conditions.map(&:clone)
        @default = @default.clone if @default
      end

      def hash
        [@case, @conditions, @default].hash
      end

      def eql?(other)
        self.class == other.class &&
          self.case == other.case &&
          conditions == other.conditions &&
          default == other.default
      end

      alias == eql?
    end

    class When < Binary
    end

    class Else < Unary
    end
  end
end

module Arel
  module Visitors
    class DepthFirst < Arel::Visitors::Visitor
      alias visit_Arel_Nodes_Else unary

      def visit_Arel_Nodes_Case(o) # rubocop:disable Style/MethodName
        visit o.case
        visit o.conditions
        visit o.default
      end

      alias visit_Arel_Nodes_When binary
    end
  end
end

module Arel
  module Predications
    def when(right)
      Nodes::Case.new(self).when quoted_node(right)
    end
  end
end

module Arel
  module Visitors
    class ToSql < Arel::Visitors::Reduce
      def visit_Arel_Nodes_Case(o, collector) # rubocop:disable Style/MethodName
        collector << 'CASE '
        if o.case
          visit o.case, collector
          collector << ' '
        end
        o.conditions.each do |condition|
          visit condition, collector
          collector << ' '
        end
        if o.default
          visit o.default, collector
          collector << ' '
        end
        collector << 'END'
      end

      def visit_Arel_Nodes_When(o, collector) # rubocop:disable Style/MethodName
        collector << 'WHEN '
        visit o.left, collector
        collector << ' THEN '
        visit o.right, collector
      end

      def visit_Arel_Nodes_Else(o, collector) # rubocop:disable Style/MethodName
        collector << 'ELSE '
        visit o.expr, collector
      end
    end
  end
end
