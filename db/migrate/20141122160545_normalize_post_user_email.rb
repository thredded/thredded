class NormalizePostUserEmail < ActiveRecord::Migration
  def change
    remove_column :thredded_posts, :user_email
  end
end
