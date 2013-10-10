# This migration comes from thredded (originally 20131005032727)
class PreventNullStickyAndLocked < ActiveRecord::Migration
  def up
    change_column_null :thredded_topics, :sticky, false, false
    change_column_null :thredded_topics, :locked, false, false
    change_column_null :thredded_topics, :posts_count, false, 0
    remove_column :thredded_topics, :attribs
  end

  def down
    add_column :thredded_topics, :attribs, :string, default: '[]'
    change_column_null :thredded_topics, :posts_count, true
    change_column_null :thredded_topics, :sticky, true
    change_column_null :thredded_topics, :locked, true
  end
end
