class AddIsActiveToNews < ActiveRecord::Migration[6.0]
  def change
    add_column :thredded_news, :isActive, :boolean, default: false
  end
end
