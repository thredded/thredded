# frozen_string_literal: true
module Thredded
  class Engine < ::Rails::Engine
    isolate_namespace Thredded

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
