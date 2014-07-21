class SetOlderPrivateTopicsAsRead < ActiveRecord::Migration
  def up
    execute <<-EOSQL
      UPDATE thredded_private_users
      SET read=true
      WHERE (updated_at < '#{60.days.ago}')
    EOSQL
  end

  def down
    execute <<-EOSQL
      UPDATE thredded_private_users
      SET read=false
    EOSQL
  end
end
