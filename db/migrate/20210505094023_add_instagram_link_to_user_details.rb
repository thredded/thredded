class AddInstagramLinkToUserDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :thredded_user_details, :instagram_url, :string
  end
end
