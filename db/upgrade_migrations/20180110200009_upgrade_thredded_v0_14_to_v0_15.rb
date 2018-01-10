# frozen_string_literal: true

require 'thredded/base_migration'

class UpgradeThreddedV014ToV015 < Thredded::BaseMigration
  def change
    remove_index :thredded_messageboard_users,
                 name: :index_thredded_messageboard_users_primary
    add_index :thredded_messageboard_users,
              %i[thredded_messageboard_id thredded_user_detail_id],
              name: :index_thredded_messageboard_users_primary,
              unique: true
  end
end
