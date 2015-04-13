module Thredded
  class Engine < ::Rails::Engine
    isolate_namespace Thredded

    config.autoload_paths << File.expand_path('../../../app/decorators', __FILE__)
    config.autoload_paths << File.expand_path('../../../app/forms', __FILE__)
    config.autoload_paths << File.expand_path('../../../app/commands', __FILE__)
    config.autoload_paths << File.expand_path('../../../app/jobs', __FILE__)

    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.helper false
    end

    config.to_prepare do
      Thredded.user_class.send(:include, Thredded::UserExtender)

      Q.setup do |config|
        config.queue = Thredded.queue_backend
        config.queue_config.inline = Thredded.queue_inline
      end

      ThreadedInMemoryQueue.logger.level = Thredded.queue_memory_log_level
    end

    initializer 'thredded.set_adapter' do
      Thredded.use_adapter! Thredded::Post.connection_config[:adapter]
    end

    initializer 'thredded.set_theme' do
      Thredded::Engine.config.assets.paths.unshift "#{Rails.root}/app/themes/#{Thredded.theme}/assets/javascripts"
      Thredded::Engine.config.assets.paths.unshift "#{Rails.root}/app/themes/#{Thredded.theme}/assets/stylesheets"
      Thredded::Engine.config.assets.paths.unshift "#{Rails.root}/app/themes/#{Thredded.theme}/assets/images"
      Thredded::Engine.config.assets.precompile += %w(thredded.css thredded.js)
      ActionController::Base.prepend_view_path("#{Rails.root}/app/themes/#{Thredded.theme}/views")
    end
  end
end
