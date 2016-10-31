# frozen_string_literal: true
require 'spec_helper'

describe '0.8 migration', migration_spec: true do
  it 'has got some users (check the sample data)' do
    expect(User.count).to be > 2
  end

  it 'migrates notifications_for_private_topics' do
    one_f_id = create(:user_preference, notify_on_message: false).id
    two_t_id = create(:user_preference, notify_on_message: true)
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
    expect(Thredded::UserPreference.find(one_f_id).notifications_for_private_topics['email']).to be_falsey
    expect(Thredded::UserPreference.find(two_t_id).notifications_for_private_topics['email']).to be_truthy
  end

  # it "smoke test" do
  #   begin
  #     verbose_was = ActiveRecord::Migration.verbose
  #     ActiveRecord::Migration.verbose = false
  #     silence_active_record do
  #       ActiveRecord::Migrator.migrate('db/upgrade_migrations') do |m|
  #         m.filename.include?('0_8')
  #       end
  #     end
  #   ensure
  #     ActiveRecord::Migration.verbose = verbose_was
  #   end
  # end
end
