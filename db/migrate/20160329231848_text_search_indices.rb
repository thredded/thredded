class TextSearchIndices < ActiveRecord::Migration
  def change
    DbTextSearch::CaseInsensitiveEq.add_index connection, :thredded_categories, :name, name: :thredded_categories_name_ci
    # Recreate previously existing MySQL index in favour of consistent names
    if connection.adapter_name.downcase =~ /mysql/
      remove_index :thredded_topics, :title
      remove_index :thredded_posts, :content
    end
    DbTextSearch::FullTextSearch.add_index connection, :thredded_topics, :title, name: :thredded_topics_title_fts
    DbTextSearch::FullTextSearch.add_index connection, :thredded_posts, :content, name: :thredded_posts_content_fts
  end
end
