class UpdateTopicCategories < ActiveRecord::Migration[6.0]
  def change
    remove_column :thredded_categories, :messageboard_id, :integer
    remove_column :thredded_categories, :slug, :string
    add_column :thredded_categories, :position, :integer, default: 0
    add_column :thredded_categories, :locked, :boolean, default: false
  end
end
