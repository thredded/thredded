# frozen_string_literal: true
source 'https://rubygems.org'

# Rails 5
gem 'rails', '~> 5.0.0.rc1'
gem 'active_record_union', git: 'https://github.com/glebm/active_record_union', branch: 'rails-5-test-harness'
group :test do
  gem 'rspec-rails', '~> 3.5.0.beta4'
  gem 'rails-controller-testing'
end

gemspec

eval_gemfile File.expand_path('shared.gemfile', File.dirname(__FILE__))
