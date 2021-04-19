class CreateRelaunchUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :thredded_relaunch_users do |t|
      t.string    :email, null: false
      t.string    :username, null: false
      t.datetime  :created_at, null: false
    end
  end
end
