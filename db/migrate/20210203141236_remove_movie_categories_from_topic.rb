class RemoveMovieCategoriesFromTopic < ActiveRecord::Migration[6.0]
  def change
    remove_column :thredded_topics, :movie_categories
  end
end
