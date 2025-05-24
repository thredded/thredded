# frozen_string_literal: true

# simplified version of active_record_union https://github.com/brianhempel/active_record_union/blob/master/lib/active_record_union/active_record/relation/union.rb

module Thredded
  module UnionScope
    extend ActiveSupport::Concern
    class_methods do
      # @param left_relation [ActiveRecord::Relation]
      # @param right_relation [ActiveRecord::Relation]
      # @return [ActiveRecord::Relation]
      def union_scope(left_relation, right_relation)
        verify_relations!(left_relation, right_relation)
        union_set = ArelCompat.union_new(self, left_relation.arel, right_relation.arel)
        from_table = Arel::Nodes::TableAlias.new(union_set, arel_table.name)
        unscoped.from(from_table)
      end

      private

      def verify_relations!(left_relation, right_relation)
        relations = [left_relation, right_relation]
        includes_relations = relations.select { |r| r.includes_values.any? }

        fail ArgumentError, 'Cannot union relation with includes.' if includes_relations.any?

        preload_relations = relations.select { |r| r.preload_values.any? }
        fail ArgumentError, 'Cannot union relation with preload.' if preload_relations.any?

        eager_load_relations = relations.select { |r| r.eager_load_values.any? }
        return unless eager_load_relations.any?

        fail ArgumentError, 'Cannot union relation with eager load.'
      end
    end
  end
end
