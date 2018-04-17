# frozen_string_literal: true

source 'https://rubygems.org'

# Rails 5
gem 'rails', '~> 5.2.0'

# Rails 5.2 deprecation warnings fixes: https://github.com/norman/friendly_id/pull/849
gem 'friendly_id', git: 'https://github.com/norman/friendly_id', ref: '4bd4300035b5c250aeb2e5feec4c2feb9bcf2a19'

group :test do
  gem 'rails-controller-testing'
end

gemspec

eval_gemfile File.expand_path('shared.gemfile', File.dirname(__FILE__))
