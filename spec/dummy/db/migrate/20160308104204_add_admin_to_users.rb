# frozen_string_literal: true
class AddAdminToUsers < (Thredded.rails_gte_51? ? ActiveRecord::Migration[5.1] : ActiveRecord::Migration)
  def change
    add_column :users, :admin, :boolean, default: false, null: false
  end
end
