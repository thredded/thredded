# frozen_string_literal: true

Dummy::Application.configure do
  config.assets.compress = false
  config.assets.debug = true
  config.assets.digest = false

  config.eager_load = false
  config.cache_classes = true

  config.action_controller.perform_caching = false
  # Raise exceptions instead of rendering exception templates.
  # using :rescuable swallows some useful debugging info for some kinds of spec errors
  config.action_dispatch.show_exceptions = :none
  config.action_controller.allow_forgery_protection = true
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
  config.action_mailer.delivery_method = :test
  config.action_mailer.perform_deliveries = true
  config.active_support.deprecation = :stderr
  config.action_controller.action_on_unpermitted_parameters = :raise
end
