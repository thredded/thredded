require 'thredded/base_migration'

class CreateThreddedNotifications < Thredded::BaseMigration
  def change
    create_table :thredded_notifications do |t|
      t.references :user, type: user_id_type, null: false, index: false
      t.string :name
      t.text :description
      t.string :url

      t.timestamps
      t.index [:user_id], name: :index_thredded_notifications_on_user_id
    end
  end
end
