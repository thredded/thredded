# frozen_string_literal: true
source 'https://rubygems.org'

# Rails 5
gem 'rails', '~> 5.0.0'

# Rails 5 compatibility PR: https://github.com/jch/html-pipeline/pull/257
# TODO: remove once merged
gem 'html-pipeline', git: 'https://github.com/jch/html-pipeline', branch: 'bump-rails-dependency'

group :test do
  gem 'rails-controller-testing'
end

gemspec

eval_gemfile File.expand_path('shared.gemfile', File.dirname(__FILE__))
