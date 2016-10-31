# frozen_string_literal: true
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment', __FILE__)

db = ENV.fetch('DB', 'sqlite3')

def silence_active_record
  was = ActiveRecord::Base.logger.level
  ActiveRecord::Base.logger.level = Logger::WARN
  yield
ensure
  ActiveRecord::Base.logger.level = was
end

# Re-create the test database and run the migrations
system({ 'DB' => db }, 'script/create-db-users') unless ENV['TRAVIS']

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
  config.infer_spec_type_from_file_location!
  config.include FactoryGirl::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers

  config.before(:suite) do
    DatabaseCleaner.strategy = :deletion
    silence_active_record do
      DatabaseCleaner.clean_with(:truncation)
    end
    ActiveJob::Base.queue_adapter = :inline
  end

  config.before(:each) do
    DatabaseCleaner.start
    Time.zone = 'UTC'
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
