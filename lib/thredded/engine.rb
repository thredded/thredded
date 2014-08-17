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
  end
end
