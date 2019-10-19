# frozen_string_literal: true

if Gem::Version.new(Sprockets::VERSION) < Gem::Version.new('4')
  Rails.application.config.assets.precompile += %w[manifest.js]
end

# Work around https://github.com/rails/sprockets/issues/581
Rails.application.config.assets.configure do |env|
  env.export_concurrent = false if env.respond_to?(:export_concurrent=)
end
