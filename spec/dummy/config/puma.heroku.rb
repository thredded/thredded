# frozen_string_literal: true
# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server

# The environment variable WEB_CONCURRENCY may be set to a default value based
# on dyno size. To manually configure this value use heroku config:set
# WEB_CONCURRENCY.
workers Integer(ENV.fetch('WEB_CONCURRENCY', 3))
threads_count = Integer(ENV.fetch('MAX_THREADS', 5))
threads(threads_count, threads_count)

preload_app!

rackup DefaultRackup
port ENV.fetch('PORT', 3000)
environment ENV.fetch('RACK_ENV', 'development')

before_fork do
  ::ActiveRecord::Base.connection_pool.disconnect!
  ::I18n.backend.send(:init_translations)
end

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
