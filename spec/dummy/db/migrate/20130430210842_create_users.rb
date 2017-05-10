# frozen_string_literal: true
class CreateUsers < (Thredded.rails_gte_51? ? ActiveRecord::Migration[5.1] : ActiveRecord::Migration)
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email

      t.timestamps null: false
    end
    DbTextSearch::CaseInsensitive.add_index connection, :users, :name
  end
end
