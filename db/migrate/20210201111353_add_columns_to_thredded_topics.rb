class AddColumnsToThreddedTopics < ActiveRecord::Migration[6.0]
  def change
    add_column :thredded_topics, :video_url, :string
    add_column :thredded_topics, :movie_categories, :text
  end
end
