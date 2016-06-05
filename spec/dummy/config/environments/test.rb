# frozen_string_literal: true
Dummy::Application.configure do
  config.assets.compress = false
  config.assets.debug = true
  config.eager_load = false
  config.cache_classes = true
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
  config.action_mailer.delivery_method = :test
  config.action_mailer.perform_deliveries = true
  config.active_support.deprecation = :stderr
end
