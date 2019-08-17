# frozen_string_literal: true

Dummy::Application.configure do
  config.eager_load = true

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  if ENV['HEROKU']
    config.middleware.use Rack::CanonicalHost, ENV['CANONICAL_HOST'] if ENV['CANONICAL_HOST']
    config.action_mailer.perform_deliveries = false
    config.active_job.queue_adapter         = :async
    config.public_file_server.enabled       = true
    config.public_file_server.headers       = { 'Cache-Control' => 'public, max-age=31536000' }
    Rails.logger                            = Logger.new(STDOUT)
    config.force_ssl                        = true
    if ENV['MEMCACHEDCLOUD_SERVERS']
      config.cache_store = :dalli_store, ENV['MEMCACHEDCLOUD_SERVERS'].split(','), {
        username: ENV['MEMCACHEDCLOUD_USERNAME'], password: ENV['MEMCACHEDCLOUD_PASSWORD']
      }
    end
  else
    config.public_file_server.enabled = false
  end

  # Compress JavaScripts and CSS
  config.assets.compress = true
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :sass

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  config.roadie.url_options = config.action_mailer.default_url_options = { host: 'thredded.org', protocol: 'https' }

  # See https://github.com/Mange/roadie-rails/blob/9e3cb2ed59f4ec9fda252ad016b23e106983a440/README.md#known-issues
  config.action_mailer.asset_host = nil

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  if Rails.gem_version >= Gem::Version.new('5.2.0')
    config.content_security_policy do |policy|
      policy.default_src :self, :https
      policy.font_src :self, :https, :data
      policy.img_src :self, :https, :data
      policy.object_src :none
      policy.script_src :self, :https
      policy.style_src :self, :https, :unsafe_inline
    end
    config.content_security_policy_nonce_generator = ->(request) {
      if request.env['HTTP_TURBOLINKS_REFERRER'].present?
        # Turbolinks nonce CSP support.
        # See https://github.com/turbolinks/turbolinks/issues/430
        request.env['HTTP_X_TURBOLINKS_NONCE']
      else
        SecureRandom.base64(16)
      end
    }
    if config.respond_to?(:content_security_policy_nonce_directives=)
      config.content_security_policy_nonce_directives = %w[script-src]
    end
  end
end
