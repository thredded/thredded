# frozen_string_literal: true

source 'https://rubygems.org'

eval_gemfile File.expand_path('spec/gemfiles/rails_7.2.gemfile', __dir__)
eval_gemfile File.expand_path('rubocop.gemfile', __dir__)
eval_gemfile File.expand_path('i18n-tasks.gemfile', __dir__)

gem 'easy_translate' if ENV['GOOGLE_TRANSLATE_API_KEY']
