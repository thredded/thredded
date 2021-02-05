# frozen_string_literal: true

class UpdateUserDetails < ActiveRecord::Migration[6.0]
  def change
    rename_column :thredded_user_details, :topics_count, :movies_count
  end
end
