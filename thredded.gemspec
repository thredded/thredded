# frozen_string_literal: true
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'thredded/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'thredded'
  s.version     = Thredded::VERSION
  s.authors     = ['Joel Oliveira', 'Gleb Mazovetskiy']
  s.email       = ['joel@thredded.com', 'glex.spb@gmail.com']
  s.homepage    = 'https://www.thredded.com'
  s.summary     = 'A messageboard engine'
  s.license     = 'MIT'
  s.description = 'A messageboard engine for Rails 4.2+ apps'

  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|script)/|^\.}) } -
            %w(Dockerfile docker-compose.yml Rakefile Gemfile shared.gemfile)

  s.required_ruby_version = '~> 2.1'

  # backend
  s.add_dependency 'bbcoder', '~> 1.0'
  s.add_dependency 'pundit', '>= 1.1.0'
  s.add_dependency 'active_record_union', '>= 1.2.0'
  s.add_dependency 'db_text_search', '~> 0.2.0'
  s.add_dependency 'friendly_id'
  s.add_dependency 'html-pipeline'
  s.add_dependency 'html-pipeline-vimeo'
  s.add_dependency 'html-pipeline-youtube'
  s.add_dependency 'htmlentities'
  s.add_dependency 'kaminari'
  s.add_dependency 'nokogiri'
  s.add_dependency 'rails', '>= 4.2.0'
  s.add_dependency 'rb-gravatar'
  s.add_dependency 'inline_svg'

  # html-pipeline dependencies, see https://github.com/jch/html-pipeline#dependencies
  s.add_dependency 'gemoji'
  s.add_dependency 'github-markdown'
  s.add_dependency 'sanitize'

  # frontend
  s.add_dependency 'sass', '>= 3.4.21'
  s.add_dependency 'autoprefixer-rails'
  s.add_dependency 'rails-timeago'
  s.add_dependency 'select2-rails', '~> 3.5'
  s.add_dependency 'autosize-rails'
  s.add_dependency 'sprockets-es6'
  s.add_dependency 'jquery-rails'

  # test dependencies
  s.add_development_dependency 'capybara', '~> 2.4'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'faker', '>= 1.6.2'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop', '~> 0.39'
  s.add_development_dependency 'test-unit'

  # dummy app dependencies
  s.add_development_dependency 'rails-i18n'
  s.add_development_dependency 'http_accept_language'
  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'puma'
  s.add_development_dependency 'rails_email_preview', '>= 2.0.1'
  s.add_development_dependency 'i18n-tasks'

  # dummy app frontend
  s.add_development_dependency 'jquery-turbolinks'
  # TODO: upgrade once Turbolinks 5 is supported by jquery-turbolinks:
  # https://github.com/kossnocorp/jquery.turbolinks/pull/58
  s.add_development_dependency 'turbolinks', '~> 2.5'
end
