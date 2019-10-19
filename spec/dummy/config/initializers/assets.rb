# frozen_string_literal: true

if Gem::Version.new(Sprockets::VERSION) < Gem::Version.new('4')
  Rails.application.config.assets.precompile += %w[manifest.js]
end
