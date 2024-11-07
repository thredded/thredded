# frozen_string_literal: true

require 'spec_helper'
Rails.env = 'test'
# To run the migration tests, run:
# MIGRATION_SPEC=1 rspec spec/migration/migration_spec.rb
RSpec.describe 'Migrations', migration_spec: true, order: :defined do # rubocop:disable RSpec/DescribeClass
  def migrate(migration_file)
    Thredded::DbTools.migrate paths: 'db/upgrade_migrations', quiet: true do |m|
      m.filename >= 'db/upgrade_migrations/20161113161801_upgrade_v0_8_to_v0_9.rb' && m.filename <= migration_file
    end
  end

  context 'v0.13 to v0.14' do
    let(:migration_file) { 'db/upgrade_migrations/20170811090735_upgrade_thredded_v0_13_to_v0_14.rb' }

    it 'smoke test' do
      migrate(migration_file)
    end
  end

  context 'v0.14 to v0.15' do
    let(:migration_file) { 'db/upgrade_migrations/20180110200009_upgrade_thredded_v0_14_to_v0_15.rb' }

    it 'smoke test' do
      migrate(migration_file)
    end
  end

  context 'v0.15 to v0.16' do
    let(:migration_file) { 'db/upgrade_migrations/20180930063614_upgrade_thredded_v0_15_to_v0_16.rb' }

    it 'smoke test' do
      migrate(migration_file)
    end
  end
end
