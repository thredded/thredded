# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 7.0.0'
gem 'rails-i18n', '~> 7.0.0'

gem 'webpacker', '~> 5.0'

gemspec

eval_gemfile File.expand_path('shared.gemfile', __dir__)
eval_gemfile File.expand_path('rubocop.gemfile', __dir__)
eval_gemfile File.expand_path('i18n-tasks.gemfile', __dir__)

gem 'easy_translate' if ENV['GOOGLE_TRANSLATE_API_KEY']
