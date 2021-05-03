class AddCategoryToTopics < ActiveRecord::Migration[6.0]
  def change
    add_column :thredded_topics, :category, :string, default: 'general'
  end
end
