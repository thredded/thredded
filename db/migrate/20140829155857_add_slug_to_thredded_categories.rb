require 'thredded/category'

class AddSlugToThreddedCategories < ActiveRecord::Migration
  def up
    add_column :thredded_categories, :slug, :string
    add_index :thredded_categories, [:messageboard_id, :slug], unique: true

    if defined?(Thredded::Category)
      Thredded::Category.all.each do |category|
        category.save!
      end
    end

    change_column_null :thredded_categories, :slug, false
  end

  def down
    remove_column :thredded_categories, :slug
  end
end
