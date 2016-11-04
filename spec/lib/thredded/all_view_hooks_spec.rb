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

  before { Thredded::AllViewHooks.current_view_context = ViewContextStub }
  after { Thredded::AllViewHooks.current_view_context = nil }

  it 'works' do
    view_hooks = Thredded::AllViewHooks.new

    sections = view_hooks.public_methods(false).reduce({}) do |h, section_name|
      h.update(section_name => view_hooks.send(section_name).public_methods(false))
    end

    sections.each do |section_name, hook_names|
      hook_names.each_with_index do |hook_name, i|
        # @type [Thredded::ViewHooks::Config]
        hook_config = view_hooks.send(section_name).send(hook_name).config
        hook_config.before { "#{hook_name} 1" }
        hook_config.before { 'before 2' }
        hook_config.replace { x } if i.even?
        hook_config.after { 'after 1' }
        hook_config.after { "#{x} 2" }
      end
    end

    sections.each do |section_name, hook_names|
      hook_names.each_with_index do |hook_name, i|
        result = view_hooks.send(section_name).send(hook_name).render { original }
        expect(result).to(eq ["#{hook_name} 1", 'before 2', (i.even? ? 'x' : 'original'), 'after 1', 'x 2'].join(''))
      end
    end
  end
end
