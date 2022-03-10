# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

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
  s.description = 'The best Rails 5.2+ forums engine ever. Its goal is to be as simple and feature rich as possible.
Thredded works with SQLite, MySQL (v5.6.4+), and PostgreSQL. See the demo at https://thredded.org/.'

  s.files = Dir['{app,bin,config,db,lib,vendor}/**/*'] + %w[MIT-LICENSE README.md]

  s.required_ruby_version = '>= 2.1', '< 4.0'

  # backend
  s.add_dependency 'active_record_union', '>= 1.3.0'
  s.add_dependency 'db_text_search'
  s.add_dependency 'friendly_id'
  s.add_dependency 'htmlentities'
  s.add_dependency 'inline_svg', '>= 1.6.0'
  s.add_dependency 'kaminari'
  s.add_dependency 'nokogiri'
  s.add_dependency 'pundit', '>= 1.1.0'
  s.add_dependency 'rails', '>= 5.2.0', '!= 6.0.0.rc2'
  s.add_dependency 'rails_gravatar'

  # post rendering
  s.add_dependency 'html-pipeline'
  s.add_dependency 'kramdown', '>= 2.0.0'
  s.add_dependency 'kramdown-parser-gfm'
  s.add_dependency 'onebox', '>= 1.8.99'
  # html-pipeline dependencies, see https://github.com/jch/html-pipeline#dependencies
  # for the AutolinkFilter
  s.add_dependency 'rinku'

  s.add_dependency 'sanitize'

  # frontend
  s.add_dependency 'autoprefixer-rails'
  s.add_dependency 'sassc-rails', '>= 2.0.0'
  s.add_dependency 'sprockets-es6'
  s.add_dependency 'timeago_js', '>= 3.0.2.2'

  # test dependencies
  s.add_development_dependency 'capybara', '~> 3.0'
  s.add_development_dependency 'capybara-screenshot'
  s.add_development_dependency 'cuprite', '>= 0.5'
  s.add_development_dependency 'database_cleaner-active_record', '~> 2.0'
  s.add_development_dependency 'factory_bot', '>= 5.0.2'
  s.add_development_dependency 'faker', '>= 1.9.3'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'rails-controller-testing'
  s.add_development_dependency 'rspec-rails', '>= 3.5.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'webmock'

  # dummy app dependencies
  s.add_development_dependency 'http_accept_language'
  s.add_development_dependency 'kaminari-i18n'
  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'puma'
  s.add_development_dependency 'rails-i18n'
  s.add_development_dependency 'rails_email_preview', '>= 2.2.1'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'twemoji'
  s.add_development_dependency 'web-console'

  # add some plugins to the dummy app demo
  s.add_development_dependency 'thredded-markdown_coderay'
  s.add_development_dependency 'thredded-markdown_katex'

  # dummy app frontend
  s.add_development_dependency 'turbolinks'
end
