$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'thredded/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'thredded'
  s.version     = Thredded::VERSION
  s.authors     = ['Joel Oliveira']
  s.email       = ['joel@thredded.com']
  s.homepage    = 'https://www.thredded.com'
  s.summary     = 'A messageboard engine'
  s.license     = 'MIT'
  s.description = 'A messageboard engine for Rails 4.0 apps'

  # backend
  s.add_dependency 'bbcoder', '~> 1.0'
  s.add_dependency 'cancancan'
  s.add_dependency 'friendly_id'
  s.add_dependency 'html-pipeline'
  s.add_dependency 'htmlentities'
  s.add_dependency 'kaminari'
  s.add_dependency 'nokogiri'
  s.add_dependency 'q'
  s.add_dependency 'rails', '>= 4.0.0'
  s.add_dependency 'rb-gravatar'

  # html-pipeline dependencies, see https://github.com/jch/html-pipeline#dependencies
  s.add_dependency 'gemoji'
  s.add_dependency 'github-markdown'
  s.add_dependency 'rinku'
  s.add_dependency 'sanitize'

  # frontend
  s.add_dependency 'bourbon'
  s.add_dependency 'neat'
  s.add_dependency 'bitters'
  s.add_dependency 'rails-timeago'
  s.add_dependency 'select2-rails', '~> 3.5'
  s.add_dependency 'autosize-rails'
  s.add_dependency 'sprockets-es6'
  s.add_dependency 'jquery-rails'

  # test dependencies
  s.add_development_dependency 'capybara', '~> 2.4'
  s.add_development_dependency 'chronic'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop', '0.32.0'
  s.add_development_dependency 'shoulda-matchers', '~> 2.7'
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'timecop'

  # dummy app dependencies
  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'puma'

  # dummy app frontend
  s.add_development_dependency 'jquery-turbolinks'
  s.add_development_dependency 'turbolinks'
end
