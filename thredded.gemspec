$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'thredded/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'thredded'
  s.version     = Thredded::VERSION
  s.authors     = ['Joel Oliveira']
  s.email       = ['joel@thredded.com']
  s.homepage    = 'https://www.thredded.com'
  s.summary     = 'A forum engine'
  s.description = 'Extracted from the full rails app at thredded.com'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'RedCloth', '4.2.9'
  s.add_dependency 'bb-ruby', '0.9.5'
  s.add_dependency 'cancan'
  s.add_dependency 'carrierwave'
  s.add_dependency 'client_side_validations'
  s.add_dependency 'coderay', '~> 1.0.6'
  s.add_dependency 'escape_utils', '0.2.3'
  s.add_dependency 'fog', '~> 1.4.0'
  s.add_dependency 'friendly_id', '~> 4.0.1'
  s.add_dependency 'gravtastic'
  s.add_dependency 'griddler'
  s.add_dependency 'htmlentities'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'kaminari', '0.13.0'
  s.add_dependency 'mini_magick'
  s.add_dependency 'multi_json'
  s.add_dependency 'nested_form', '~> 0.2.0'
  s.add_dependency 'nokogiri'
  s.add_dependency 'pseudohelp'
  s.add_dependency 'rails', '~> 3.2.13'
  s.add_dependency 'rails_emoji', '~> 1.5'
  s.add_dependency 'redcarpet', '~> 2.1.1'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'chronic'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'timecop'
end
