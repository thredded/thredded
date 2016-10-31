require "spec_helper"

describe "0.8 migration", migration_spec: true do

  it "has got some users" do
    expect(User.count).to be >(2)
  end

  it "smoke test" do
    begin
      verbose_was = ActiveRecord::Migration.verbose
      ActiveRecord::Migration.verbose = false
      silence_active_record do
        ActiveRecord::Migrator.migrate('db/upgrade_migrations') do |m|
          m.filename.include?('0_8')
        end
      end
    ensure
      ActiveRecord::Migration.verbose = verbose_was
    end

    expect(true).to be_falsey
  end
end
