# frozen_string_literal: true

Capybara.register_server :puma do |app, port, host|
  require 'rack/handler/puma'
  Rack::Handler::Puma.run(app, Host: host, Port: port, Threads: '1:1')
end

Capybara.asset_host = ENV.fetch('CAPYBARA_ASSET_HOST', 'http://localhost:3011') unless ENV['CI']

module BetterRailsSystemTests
  # Use our `Capybara.save_path` to store screenshots with other capybara artifacts
  # (Rails screenshots path is not configurable https://github.com/rails/rails/blob/49baf092439fc74fc3377b12e3334c3dd9d0752f/actionpack/lib/action_dispatch/system_testing/test_helpers/screenshot_helper.rb#L79)
  def absolute_image_path
    Rails.root.join("#{Capybara.save_path}/screenshots/#{image_name}.png")
  end

  # Make failure screenshots compatible with multi-session setup.
  # That's where we use Capybara.last_used_session introduced before.
  def take_screenshot
    return super unless Capybara.last_used_session

    Capybara.using_session(Capybara.last_used_session) { super }
  end
end

RSpec.configure do |config|
  config.include BetterRailsSystemTests, type: :system

  # Make urls in mailers contain the correct server host.
  # It's required for testing links in emails (e.g., via capybara-email).
  config.around(:each, type: :system) do |ex|
    was_host = Rails.application.default_url_options[:host]
    Rails.application.default_url_options[:host] = Capybara.server_host
    ex.run
    Rails.application.default_url_options[:host] = was_host
  end

  # Make sure this hook runs before others
  config.prepend_before(:each, type: :system) do |example|
    if example.metadata[:js]
      puts "driven by #{Capybara.javascript_driver}"
      driven_by(Capybara.javascript_driver)
    else
      puts 'driven by rack test'
      driven_by(:rack_test)
    end
  end
end
