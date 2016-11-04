# frozen_string_literal: true
require 'spec_helper'

describe Thredded::AllViewHooks do
  module ViewContextStub
    module_function

    def x
      'x'
    end

    def original
      'original'
    end

    def safe_join(arr, sep)
      arr.join(sep)
    end

    def capture(&block)
      instance_exec(&block)
    end
  end

  it 'works' do
    config = Thredded::AllViewHooks::Config.new
    renderer = Thredded::AllViewHooks::Renderer.new(ViewContextStub, config: config)

    config_sections = config.public_methods(false).reduce({}) do |h, section_name|
      h.update(section_name => config.send(section_name).public_methods(false))
    end
    renderer_sections = renderer.public_methods(false).reduce({}) do |h, section_name|
      h.update(section_name => renderer.send(section_name).public_methods(false))
    end

    expect(config_sections).to eq(renderer_sections)

    config_sections.each do |config_section_name, hook_names|
      hook_names.each_with_index do |hook_name, i|
        # @type [Thredded::ViewHooks::Config]
        hook_config = config.send(config_section_name).send(hook_name)
        hook_config.before { "#{hook_name} 1" }
        hook_config.before { 'before 2' }
        hook_config.replace { x } if i.even?
        hook_config.after { 'after 1' }
        hook_config.after { "#{x} 2" }
      end
    end

    renderer_sections.each do |renderer_section_name, hook_names|
      hook_names.each_with_index do |hook_name, i|
        result = renderer.send(renderer_section_name).send(hook_name) { original }
        expect(result).to(eq ["#{hook_name} 1", 'before 2', (i.even? ? 'x' : 'original'), 'after 1', 'x 2'].join(''))
      end
    end
  end
end
