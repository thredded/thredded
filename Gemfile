# frozen_string_literal: true

source 'https://rubygems.org'

# Rails 5
gem 'rails', '~> 5.2.2'

# https://github.com/rails/rails/blob/v5.2.2/activerecord/lib/active_record/connection_adapters/sqlite3_adapter.rb#L12
gem 'sqlite3', '~> 1.3.6'

group :test do
  gem 'rails-controller-testing'
end

gemspec

eval_gemfile File.expand_path('shared.gemfile', File.dirname(__FILE__))
