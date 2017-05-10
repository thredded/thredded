# frozen_string_literal: true

module Thredded
  class BaseMigration < (Thredded.rails_gte_51? ? ActiveRecord::Migration[5.1] : ActiveRecord::Migration)
    def user_id_type
      Thredded.user_class.columns.find { |c| c.name == Thredded.user_class.primary_key }.sql_type
    end

    def column_type(table, column_name)
      column_name = column_name.to_s
      columns(table).find { |c| c.name == column_name }.sql_type
    end
  end
end
