# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 6.0.0'
gem 'rails-i18n', '~> 6.0.0'
gem 'webpacker', '~> 4.2'
gem 'fast_jsonapi', '~> 1.5'

# https://github.com/rails/rails/blob/v6.0.0.rc1/activerecord/lib/active_record/connection_adapters/sqlite3_adapter.rb#L12
gem 'sqlite3', '~> 1.3', '>= 1.3.6'

group :test do
  gem 'rails-controller-testing'

  # https://github.com/rspec/rspec-rails/issues/2103
  gem 'rspec-rails', '>= 4.0.0.beta2'
end

gemspec

eval_gemfile File.expand_path('shared.gemfile', __dir__)
eval_gemfile File.expand_path('rubocop.gemfile', __dir__)
eval_gemfile File.expand_path('i18n-tasks.gemfile', __dir__)
