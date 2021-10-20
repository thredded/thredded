# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 6.1.0'
gem 'rails-i18n', '~> 6.0.0'

gem 'webpacker', '~> 4.2'

# https://github.com/rails/rails/blob/v6.0.0/activerecord/lib/active_record/connection_adapters/sqlite3_adapter.rb#L13
gem 'sqlite3', '~> 1.4'

group :test do
  gem 'rails-controller-testing'

  # https://github.com/rspec/rspec-rails/issues/2103
  gem 'rspec-rails', '>= 4.0.0.beta2'
end

gemspec

eval_gemfile File.expand_path('shared.gemfile', __dir__)
eval_gemfile File.expand_path('rubocop.gemfile', __dir__)
eval_gemfile File.expand_path('i18n-tasks.gemfile', __dir__)
