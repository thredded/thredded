# frozen_string_literal: true

class UpgradeV03ToV04 < ActiveRecord::Migration[5.0]
  def up
    create_table :thredded_messageboard_groups do |t|
      t.string :name
      t.timestamps null: false
    end

    add_column :thredded_messageboards, :thredded_messageboard_group_id, :integer
    add_index :thredded_messageboards, [:thredded_messageboard_group_id],
              name: :index_thredded_messageboards_on_messageboard_group_id
  end
end
