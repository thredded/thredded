# frozen_string_literal: true

module Thredded
  class Engine < ::Rails::Engine
    isolate_namespace Thredded

    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.helper false
    end

    config.to_prepare do
      Thredded::AllViewHooks.reset_instance!
      Thredded.user_class&.send(:include, Thredded::UserExtender)
    end

    initializer 'thredded.setup_assets' do
      Thredded::Engine.config.assets.precompile += %w[
        thredded_manifest.js
      ]
    end

    config.after_initialize do |app|
      if !Rails.env.production? && !app.assets.preprocessors.keys.include?("text/scss")
        raise %(Thredded requires a Sass compiler to be registered in Sprockets. Please add "sassc-rails" or "dartsass-sprockets" to your application Gemfile.)
      end
    end
  end
end
