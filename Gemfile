# frozen_string_literal: true

source 'https://rubygems.org'

# Rails 5
gem 'rails', '~> 5.1.0'

# On Rails < 5.2, only pg < v1 is supported. See:
# https://github.com/rails/rails/pull/31671
# https://bitbucket.org/ged/ruby-pg/issues/270/pg-100-x64-mingw32-rails-server-not-start
gem 'pg', '~> 0.21'

group :test do
  gem 'rails-controller-testing'
end

gemspec

eval_gemfile File.expand_path('shared.gemfile', File.dirname(__FILE__))
