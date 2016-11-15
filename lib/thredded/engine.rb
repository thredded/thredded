# frozen_string_literal: true
module Thredded
  class Engine < ::Rails::Engine
    isolate_namespace Thredded

    # All of the paths Thredded needs are already in the default Rails paths.
    # However, the lib paths is not autoloaded by default. Make it *autoload* to make developing Thredded easier.
    # Do not *eager_load* because not all the code in lib should be loaded in production.
    # The code in lib that should be loaded in production is required explicitly via `require_dependency`.
    config.paths['lib'].autoload!

    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.helper false
    end

    config.to_prepare do
      Thredded::AllViewHooks.reset_instance!
      if Thredded.user_class
        Thredded.user_class.send(:include, Thredded::UserExtender)
      end
    end

    initializer 'thredded.setup_assets' do
      Thredded::Engine.config.assets.precompile += %w(
        thredded.js
        thredded.css
        thredded/*.svg
      )
    end
  end
end
