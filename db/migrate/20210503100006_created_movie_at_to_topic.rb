class CreatedMovieAtToTopic < ActiveRecord::Migration[6.0]
  def change
    add_column :thredded_topics, :movie_created_at, :datetime
  end
end
