# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'thredded/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s| # rubocop:disable Metrics/BlockLength
  s.name        = 'thredded'
  s.version     = Thredded::VERSION
  s.authors     = ['Joel Oliveira', 'Gleb Mazovetskiy']
  s.email       = ['joel@thredded.com', 'glex.spb@gmail.com']
  s.homepage    = 'https://thredded.org'
  s.summary     = 'The best Rails forums engine ever.'
  s.license     = 'MIT'
  s.description = 'The best Rails 4.2+ forums engine ever. Its goal is to be as simple and feature rich as possible.
Thredded works with SQLite, MySQL (v5.6.4+), and PostgreSQL. See the demo at https://thredded.org/.'

  s.files = Dir['{app,bin,config,db,lib,vendor}/**/*'] + %w[MIT-LICENSE README.md]

  s.required_ruby_version = '~> 2.1'

  # backend
  s.add_dependency 'pundit', '>= 1.1.0'
  s.add_dependency 'active_record_union', '>= 1.2.0'
  s.add_dependency 'db_text_search', '~> 0.2.0'
  s.add_dependency 'friendly_id'
  s.add_dependency 'htmlentities'
  s.add_dependency 'kaminari'
  s.add_dependency 'nokogiri'
  s.add_dependency 'rails', '>= 4.2.0'
  s.add_dependency 'rb-gravatar'
  s.add_dependency 'inline_svg'

  # post rendering
  s.add_dependency 'kramdown'
  s.add_dependency 'onebox', '~> 1.8', '>= 1.8.13'
  s.add_dependency 'html-pipeline'
  # html-pipeline dependencies, see https://github.com/jch/html-pipeline#dependencies
  # for the AutolinkFilter
  s.add_dependency 'rinku'

  # gemoji v3 removes most of the emoji from the gem, so lock to v2 until we find another solution.
  s.add_dependency 'gemoji', '~> 2.1.0'

  s.add_dependency 'sanitize'

  # frontend
  s.add_dependency 'sass', '>= 3.4.21'
  s.add_dependency 'autoprefixer-rails'
  s.add_dependency 'timeago_js'
  s.add_dependency 'sprockets-es6'

  # test dependencies
  s.add_development_dependency 'capybara', '~> 2.4'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'faker', '>= 1.6.2'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'rspec-rails', '>= 3.5.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rubocop', '= 0.49.1'

  # dummy app dependencies
  s.add_development_dependency 'rails-i18n'
  s.add_development_dependency 'kaminari-i18n'
  s.add_development_dependency 'http_accept_language'
  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'puma'
  s.add_development_dependency 'rails_email_preview', '>= 2.0.1'
  s.add_development_dependency 'roadie-rails'
  s.add_development_dependency 'i18n-tasks'
  s.add_development_dependency 'web-console'

  # add some plugins to the dummy app demo
  s.add_development_dependency 'thredded-markdown_coderay'
  s.add_development_dependency 'thredded-markdown_katex'

  # dummy app frontend
  s.add_development_dependency 'turbolinks'
  # required by the turbolinks gem
  s.add_development_dependency 'coffee-rails'
end
