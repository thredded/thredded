class AddPolymorphicAssocToPosts < ActiveRecord::Migration
  def up
    add_column :thredded_posts, :postable_type, :string, limit: 191

    execute <<-SQL
      UPDATE thredded_posts tp
      INNER JOIN thredded_private_topics tpt ON tpt.id = tp.topic_id
      SET tp.postable_type = 'Thredded::PrivateTopic'
    SQL

    execute <<-SQL
      UPDATE thredded_posts
      SET postable_type='Thredded::Topic'
      WHERE postable_type IS NULL
    SQL

    rename_column :thredded_posts, :topic_id, :postable_id
    remove_column :thredded_posts, :private_topic_id
    add_index :thredded_posts, [:postable_id, :postable_type]
  end

  def down
    add_column :thredded_posts, :private_topic_id, :integer
    rename_column :thredded_posts, :postable_id, :topic_id

    execute <<-SQL
      UPDATE thredded_posts SET topic_id=postable_id
      WHERE postable_type='Thredded::Topic'
    SQL

    execute <<-SQL
      UPDATE thredded_posts SET private_topic_id=postable_id
      WHERE postable_type='Thredded::PrivateTopic'
    SQL

    remove_column :thredded_posts, :postable_id
    remove_column :thredded_posts, :postable_type

    add_index :thredded_posts, :topic_id
    add_index :thredded_posts, :private_topic_id
  end
end
