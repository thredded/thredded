# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] = 'test'
require File.expand_path('../dummy/config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'factory_girl_rails'
require 'shoulda-matchers'
require 'chronic'

Dir[Rails.root.join('../../spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/../../spec/fixtures"
  config.use_transactional_fixtures = true
  config.include FactoryGirl::Syntax::Methods


  config.before(:each) do
    Time.zone = 'UTC'
    Chronic.time_class = Time.zone
  end
end
