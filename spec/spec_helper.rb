# frozen_string_literal: true

def require_rel(*paths)
  # Handle passing an array as an argument
  paths.flatten!
  return false if paths.empty?

  source_directory = File.dirname caller(1..1).first.sub(/:\d+$/, '')
  paths.each do |path|
    require_all File.join(source_directory, path)
  end
end

ENV['RAILS_ENV'] = 'test'
db = ENV.fetch('DB', 'sqlite3')

if ENV['COVERAGE'] && !%w[rbx jruby].include?(RUBY_ENGINE)
  require 'simplecov'
  SimpleCov.command_name ENV['SIMPLECOV_NAME'] || 'RSpec'
end

require File.expand_path('dummy/config/environment', __dir__)

FileUtils.mkdir('log') unless File.directory?('log')

# If desired can log SQL to STDERR -- this tends to overload travis' log limits though.
if ENV['LOG_SQL_TO_STDERR']
  Rails.logger = Logger.new(STDERR)
  Rails.logger.level = Logger::WARN
  ActiveRecord::Base.logger = Logger.new(STDERR)
  ActiveRecord::Base.logger.level = Logger::DEBUG
elsif !ENV['TRAVIS']
  ActiveRecord::SchemaMigration.logger = ActiveRecord::Base.logger = Logger.new(File.open("log/test.#{db}.log", 'w'))
end

# Re-create the test database and run the migrations
system({ 'DB' => db }, 'script/create-db-users') unless ENV['TRAVIS'] || ENV['DOCKER']
ActiveRecord::Tasks::DatabaseTasks.drop_current
ActiveRecord::Tasks::DatabaseTasks.create_current
require File.expand_path('../lib/thredded/db_tools', __dir__)
if ENV['MIGRATION_SPEC']
  Thredded::DbTools.restore
else
  Thredded::DbTools.migrate(paths: ['db/migrate/', Rails.root.join('db', 'migrate')], quiet: true)
end

require File.expand_path('../spec/support/features/page_object/authentication', __dir__)
require 'rspec/rails'
require 'pundit/rspec'
require 'webmock/rspec'
require 'factory_bot'
require 'database_cleaner'
require 'fileutils'
require 'active_support/testing/time_helpers'
require 'dry-validation'
require 'require_all'
require 'file_validators'
require_rel './support/views/schemas'

WebMock.allow_net_connect!

if Rails::VERSION::MAJOR >= 5
  require 'rails-controller-testing'
  RSpec.configure do |config|
    %i[controller view request].each do |type|
      config.include ::Rails::Controller::Testing::TestProcess, type: type
      config.include ::Rails::Controller::Testing::TemplateAssertions, type: type
      config.include ::Rails::Controller::Testing::Integration, type: type
    end
  end
else
  module Rails5StyleRequestMethods
    %i[get post patch delete].each do |m|
      define_method m do |path, params: {}, **args|
        super(path, args.merge(params))
      end
    end
  end
  RSpec.configure do |config|
    %i[controller request].each do |type|
      config.prepend Rails5StyleRequestMethods, type: type
    end
  end
end

def with_thredded_setting(setting, value)
  was = Thredded.send(setting)
  Thredded.send(:"#{setting}=", value)
  yield
ensure
  Thredded.send(:"#{setting}=", was)
end

Dir[Rails.root.join('..', '..', 'spec', 'support', '**', '*.rb')].each { |f| require f }

RSpec.configure do |config| # rubocop:disable Metrics/BlockLength
  if ENV['MIGRATION_SPEC']
    config.filter_run_excluding migration_spec: false
  else
    config.filter_run_excluding migration_spec: true
  end
  config.infer_spec_type_from_file_location!
  config.include FactoryBot::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers
  config.before(:suite) do
    require_relative './factories'
  end

  if ENV['MIGRATION_SPEC']
    config.before(:each, migration_spec: true) do
      DatabaseCleaner.strategy = :transaction unless Thredded::DbTools.adapter =~ /mysql/i
      DatabaseCleaner.start unless Thredded::DbTools.adapter =~ /mysql/i
    end

    config.after(:each, migration_spec: true) do
      if Thredded::DbTools.adapter =~ /mysql/i
        ActiveRecord::Tasks::DatabaseTasks.drop_current
        ActiveRecord::Tasks::DatabaseTasks.create_current
        Thredded::DbTools.restore
      else
        DatabaseCleaner.clean
      end
    end
  else
    config.before(:suite) do
      Thredded::DbTools.silence_active_record do
        DatabaseCleaner.clean_with(:truncation, reset_ids: true)
      end
      if Rails::VERSION::MAJOR < 5
        # after_commit testing is baked into rails 5.
        require 'test_after_commit'
        TestAfterCommit.enabled = true
      end
      ActiveJob::Base.queue_adapter = :inline
    end

    config.before do
      DatabaseCleaner.strategy = :transaction
    end

    config.before(:each, type: :feature) do
      # :rack_test driver's Rack app under test shares database connection
      # with the specs, so continue to use transaction strategy for speed.
      shared_db_connection = Capybara.current_driver == :rack_test

      unless shared_db_connection
        # Driver is probably for an external browser with an app
        # under test that does *not* share a database connection with the
        # specs, so use truncation strategy.
        DatabaseCleaner.strategy = :truncation, { reset_ids: true, cache_tables: true }
      end
    end

    config.before do
      Time.zone = 'UTC'
      DatabaseCleaner.start
    end

    config.append_after do
      DatabaseCleaner.clean
    end
  end
end
