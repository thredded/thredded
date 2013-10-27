class ConvertTextileToMarkdown < ActiveRecord::Migration
  def up
    execute <<-sql
      UPDATE thredded_posts SET filter='markdown' WHERE filter == 'textile'
    sql
  end
end
