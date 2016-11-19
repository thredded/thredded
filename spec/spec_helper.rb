# frozen_string_literal: true
ENV['RAILS_ENV'] = 'test'
db = ENV.fetch('DB', 'sqlite3')

if ENV['COVERAGE'] && !%w(rbx jruby).include?(RUBY_ENGINE) && !ENV['MIGRATION_SPEC']
  require 'simplecov'
  SimpleCov.command_name 'RSpec'
end

require File.expand_path('../dummy/config/environment', __FILE__)

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
system({ 'DB' => db }, 'script/create-db-users') unless ENV['TRAVIS']
ActiveRecord::Tasks::DatabaseTasks.drop_current
ActiveRecord::Tasks::DatabaseTasks.create_current
require File.expand_path('../../lib/thredded/db_tools', __FILE__)
if ENV['MIGRATION_SPEC']
  Thredded::DbTools.restore
else
  begin
    verbose_was = ActiveRecord::Migration.verbose
    ActiveRecord::Migration.verbose = false
    Thredded::DbTools.silence_active_record do
      ActiveRecord::Migrator.migrate(['db/migrate/', File.join(Rails.root, 'db/migrate/')])
    end
  ensure
    ActiveRecord::Migration.verbose = verbose_was
  end
end

require File.expand_path('../../spec/support/features/page_object/authentication', __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'pundit/rspec'
require 'factory_girl_rails'
require 'database_cleaner'
require 'fileutils'
require 'active_support/testing/time_helpers'

if Rails::VERSION::MAJOR >= 5
  require 'rails-controller-testing'
  RSpec.configure do |config|
    [:controller, :view, :request].each do |type|
      config.include ::Rails::Controller::Testing::TestProcess, type: type
      config.include ::Rails::Controller::Testing::TemplateAssertions, type: type
      config.include ::Rails::Controller::Testing::Integration, type: type
    end
  end
else
  module Rails5StyleRequestMethods
    %i(get post patch delete).each do |m|
      define_method m do |path, params: {}, **args|
        super(path, args.merge(params))
      end
    end
  end
  RSpec.configure do |config|
    [:controller, :request].each do |type|
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

Dir[Rails.root.join('../../spec/support/**/*.rb')].each { |f| require f }

counter = -1

FileUtils.mkdir('log') unless File.directory?('log')

RSpec.configure do |config|
  if ENV['MIGRATION_SPEC']
    config.filter_run_excluding migration_spec: false
  else
    config.filter_run_excluding migration_spec: true
  end
  config.infer_spec_type_from_file_location!
  config.include FactoryGirl::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers

  if ENV['MIGRATION_SPEC']
    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction unless Thredded::DbTools.adapter =~ /mysql/i
    end

    config.before(:each) do
      DatabaseCleaner.start unless Thredded::DbTools.adapter =~ /mysql/i
    end

    config.after(:each) do
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
      DatabaseCleaner.strategy = :transaction
      Thredded::DbTools.silence_active_record do
        DatabaseCleaner.clean_with(:truncation)
      end
      if Rails::VERSION::MAJOR < 5
        # after_commit testing is baked into rails 5.
        require 'test_after_commit'
        TestAfterCommit.enabled = true
      end
      ActiveJob::Base.queue_adapter = :inline
    end

    config.after(:suite) do
      counter = 0
    end

    config.before(:each) do
      DatabaseCleaner.start
      Time.zone = 'UTC'
    end

    config.after(:each) do
      DatabaseCleaner.clean
      counter += 1
      if counter > 9
        GC.enable
        GC.start
        GC.disable
        counter = 0
      end
    end
  end
end
