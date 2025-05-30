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
      next unless Rails.env.development? || Rails.env.test?
      next unless app.config.assets.compile && app.assets

      if app.assets.preprocessors.keys.exclude?('text/scss')
        fail [
          'Thredded requires a Sass compiler to be registered in Sprockets.',
          %(Please add "sassc-rails" or "dartsass-sprockets" to your application Gemfile.),
        ].join(' ')
      end
    end
  end
end
