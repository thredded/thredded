class RemoveFilterFromMessageboards < ActiveRecord::Migration
  def up
    remove_column :thredded_messageboards, :filter
    remove_column :thredded_posts, :filter
    remove_column :thredded_private_posts, :filter
  end

  def down
    add_column :thredded_private_posts, :filter, :string, default: 'markdown', null: false
    add_column :thredded_posts, :filter, :string, default: 'markdown', null: false
    add_column :thredded_messageboards, :filter, :string, default: 'markdown', null: false
  end
end
