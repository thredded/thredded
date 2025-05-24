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
  s.description = 'The best Rails 6.0+ forums engine ever. Its goal is to be as simple and feature rich as possible.
Thredded works with SQLite, MySQL (v5.6.4+), and PostgreSQL. See the demo at https://thredded.org/.'

  s.files = Dir['{app,bin,config,db,lib,vendor}/**/*'] + %w[MIT-LICENSE README.md]

  s.required_ruby_version = '>= 3.1', '< 4.0'

  # backend
  s.add_dependency 'db_text_search'
  s.add_dependency 'friendly_id'
  s.add_dependency 'htmlentities'
  s.add_dependency 'inline_svg', '>= 1.6.0'
  s.add_dependency 'kaminari'
  s.add_dependency 'nokogiri'
  s.add_dependency 'pundit', '>= 1.1.0'
  s.add_dependency 'rails', '>= 7.0'
  s.add_dependency 'rails_gravatar'

  # post rendering
  s.add_dependency 'html-pipeline', '>= 2.14.1', '< 3'
  s.add_dependency 'kramdown', '>= 2.0.0'
  s.add_dependency 'kramdown-parser-gfm'
  s.add_dependency 'onebox', '>= 1.8.99'
  # html-pipeline dependencies, see https://github.com/jch/html-pipeline#dependencies
  # for the AutolinkFilter
  s.add_dependency 'rinku'

  s.add_dependency 'sanitize'

  # frontend
  s.add_dependency 'autoprefixer-rails'
  s.add_dependency 'sprockets-es6'
  s.add_dependency 'timeago_js', '>= 3.0.2.2'
end
