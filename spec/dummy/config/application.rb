# frozen_string_literal: true

require File.expand_path('boot', __dir__)

require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
require 'http_accept_language'
require 'rails-i18n'
require 'kaminari-i18n'
require 'turbolinks'
require 'rails_email_preview'
require 'roadie-rails'
require 'twemoji'
require 'twemoji/svg'
require 'thredded'
require 'thredded/markdown_coderay'
require 'thredded/markdown_katex'
require 'rails-ujs' unless Thredded.rails_gte_51?
require 'backport_new_renderer' if Rails::VERSION::MAJOR < 5

if ENV['HEROKU']
  require 'tunemygc'
  require 'rack/canonical_host'
  require 'newrelic_rpm'
  require 'dalli'
end

require 'web-console' if Rails.env.development?

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    config.i18n.available_locales = %i[en] + %i[es fr de it pl pt-BR ru zh-CN].sort

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    config.active_record.raise_in_transactional_callbacks = true if Rails::VERSION::MAJOR < 5

    if Rails.gem_version >= Gem::Version.new('5.2.0.beta2')
      config.active_record.sqlite3.represent_boolean_as_integer = true
    end

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end
end
