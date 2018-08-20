# frozen_string_literal: true

require 'spec_helper'

FactoryBot.factories.map(&:name).each do |factory_name|
  describe "factory #{factory_name}" do
    it 'is valid' do
      factory = build(factory_name)

      expect(factory).to be_valid, factory.errors.full_messages.join(',') if factory.respond_to?(:valid?)
    end
  end
end
