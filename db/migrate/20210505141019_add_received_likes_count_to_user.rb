class AddReceivedLikesCountToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :thredded_user_details, :received_likes_movies, :integer, default: 0
  end
end
