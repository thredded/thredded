# frozen_string_literal: true

require 'spec_helper'
require 'factories'

RSpec.describe 'Factory' do # rubocop:disable RSpec/DescribeClass
  FactoryBot.factories.map(&:name).each do |factory_name|
    it "#{factory_name} is valid" do
      instance = create(factory_name)
      if instance.respond_to?(:valid?)
        expect(instance).to(be_valid, -> { "#{factory_name}: #{instance.errors.full_messages.join(', ')}" })
      end
    end
  end
end
