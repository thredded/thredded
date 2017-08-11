# frozen_string_literal: true

require 'thredded/base_migration'

class UpgradeThreddedV013ToV014 < Thredded::BaseMigration
  def change
    remove_index :thredded_user_details,
                 name: :index_thredded_user_details_on_user_id
    add_index :thredded_user_details,
              name: :index_thredded_user_details_on_user_id,
              unique: true
    remove_index :thredded_user_preferences,
                 name: :index_thredded_user_preferences_on_user_id
    add_index :thredded_user_preferences,
              name: :index_thredded_user_preferences_on_user_id,
              unique: true
  end
end
