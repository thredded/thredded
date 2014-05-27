class AddPolymorphicAssocToPosts < ActiveRecord::Migration
  def up
    add_column :thredded_posts, :postable_type, :string
    execute <<-SQL
      UPDATE thredded_posts SET postable_type='Thredded::PrivateTopic'
      WHERE private_topic_id IS NOT NULL
    SQL
    rename_column :thredded_posts, :private_topic_id, :postable_id

    execute <<-SQL
      UPDATE thredded_posts SET postable_type='Thredded::Topic'
      WHERE topic_id IS NOT NULL
    SQL

    execute <<-SQL
      UPDATE thredded_posts SET postable_id=topic_id
      WHERE topic_id IS NOT NULL
    SQL

    remove_column :thredded_posts, :topic_id
    add_index :thredded_posts, [:postable_id, :postable_type]
  end

  def down
    add_column :thredded_posts, :topic_id, :integer
    add_column :thredded_posts, :private_topic_id, :integer
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
