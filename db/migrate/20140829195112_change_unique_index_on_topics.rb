class ChangeUniqueIndexOnTopics < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.index_exists?(:thredded_topics, :slug)
      remove_index :thredded_topics, :slug
    end

    add_index :thredded_topics, [:messageboard_id, :slug], unique: true
  end

  def down
    remove_index :thredded_topics, [:messageboard_id, :slug]
    add_index :thredded_topics, :slug
  end
end
