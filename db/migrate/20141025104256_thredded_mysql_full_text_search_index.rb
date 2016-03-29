class ThreddedMysqlFullTextSearchIndex < ActiveRecord::Migration
  def up
    if connection.adapter_name.downcase =~ /mysql/
      add_index :thredded_topics, :title, type: :fulltext
      add_index :thredded_posts, :content, type: :fulltext
    end
  end

  def down
    if connection.adapter_name.downcase =~ /mysql/
      remove_index :thredded_topics, :title
      remove_index :thredded_posts, :content
    end
  end
end
