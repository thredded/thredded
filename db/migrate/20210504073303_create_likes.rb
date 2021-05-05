require 'thredded/base_migration'

class CreateLikes < Thredded::BaseMigration
  def change
    create_table :thredded_likes do |t|
      t.references :topic, null: false
      t.references :user, type: user_id_type, null: false, index: false
      t.timestamps
      t.index [:user_id], name: :index_thredded_likes_on_user_id
    end
  end
end
