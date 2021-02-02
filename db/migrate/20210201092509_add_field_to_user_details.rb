class AddFieldToUserDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :thredded_user_details, :profile_description, :text
    add_column :thredded_user_details, :occupation, :string
    add_column :thredded_user_details, :location, :string
    add_column :thredded_user_details, :camera, :string
    add_column :thredded_user_details, :cutting_program, :string
    add_column :thredded_user_details, :sound, :string
    add_column :thredded_user_details, :lighting, :string
    add_column :thredded_user_details, :website_url, :string
    add_column :thredded_user_details, :youtube_url, :string
    add_column :thredded_user_details, :facebook_url, :string
    add_column :thredded_user_details, :twitter_url, :string
    add_column :thredded_user_details, :interests, :text
  end
end
