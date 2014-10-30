class SetOlderPrivateTopicsAsRead < ActiveRecord::Migration
  def up
    execute <<-EOSQL
      UPDATE thredded_private_users
      SET #{quote_column_name 'read'}=#{quoted_true}
      WHERE updated_at < #{quote connection.quoted_date 60.days.ago.to_date}
    EOSQL
  end

  def down
    execute <<-EOSQL
      UPDATE thredded_private_users
      SET #{quote_column_name 'read'}=#{quoted_false}
    EOSQL
  end
end
