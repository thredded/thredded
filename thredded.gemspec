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

  s.add_dependency 'rails', '~> 3.2.13'
  s.add_dependency 'jquery-rails'

  s.add_development_dependency 'pg'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'shoulda-matchers'
end
