class AddMoviesCountToMessageboard < ActiveRecord::Migration[6.0]
  def change
    add_column :thredded_messageboards, :movies_count, :integer, default: 0
  end
end
