# frozen_string_literal: true
require 'thredded/base_migration'

class CreateUsers < Thredded::BaseMigration
  def change
    create_table :users do |t|
      t.text :name, null: false
      t.text :email

      t.timestamps null: false
    end
    DbTextSearch::CaseInsensitive.add_index connection, :users, :name,
                                            **(max_key_length ? { length: max_key_length } : {})
  end
end
