module Thredded
  class Engine < ::Rails::Engine
    isolate_namespace Thredded

    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.helper false
    end
  end
end
