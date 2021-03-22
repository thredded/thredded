class CreateBadges < ActiveRecord::Migration[6.0]
  def change
    create_table :thredded_badges do |t|
      t.string :title
      t.text :description
      t.boolean :secret, null: false, default: false

      t.timestamps
    end

    create_table :thredded_user_badges do |t|
      t.references :user, null: false, index: false
      t.references :badge, null: false, index: false
      t.index [:user_id], name: :index_thredded_user_badges_on_user_id
      t.index [:badge_id], name: :index_thredded_user_badges_on_badge_id
    end
  end
end
