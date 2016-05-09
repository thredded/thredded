# frozen_string_literal: true
require_dependency 'thredded/main_app_route_delegator'
module Thredded
  class Engine < ::Rails::Engine
    isolate_namespace Thredded

    %w(app/view_models app/forms app/commands app/jobs lib).each do |path|
      config.autoload_paths << File.expand_path("../../#{path}", File.dirname(__FILE__))
    end

    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.helper false
    end

    config.to_prepare do
      if Thredded.user_class
        Thredded.user_class.send(:include, Thredded::UserExtender)
      end

      # Delegate all main_app routes to allow calling them directly.
      ::Thredded::ApplicationController.helper ::Thredded::MainAppRouteDelegator
    end

    initializer 'thredded.setup_assets' do
      Thredded::Engine.config.assets.precompile += %w(
        thredded.js
        thredded.css
        thredded/*.svg
      )
    end

    initializer 'thredded.setup_bbcoder' do
      BBCoder.configure do
        tag :img, match: %r{^https?://.*(png|bmp|jpe?g|gif)$}, singular: false do
          %(<img src="#{singular? ? meta : content}" />)
        end

        tag :spoilers do
          %(<span class="thredded--post--content--spoiler">#{content}</span>)
        end

        tag :spoiler do
          %(<span class="thredded--post--content--spoiler">#{content}</span>)
        end
      end
    end
  end
end
