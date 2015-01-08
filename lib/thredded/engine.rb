module Thredded
  class Engine < ::Rails::Engine
    isolate_namespace Thredded
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
  end
end
