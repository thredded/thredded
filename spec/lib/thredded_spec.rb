# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Thredded do
  context '.user_path', thredded_reset: [:@user_path] do
    it 'returns one path' do
      me = build_stubbed(:user, name: 'joel')
      described_class.user_path = ->(user) { "/my/name/is/#{user.name}" }
      expect(described_class.user_path(_view_context = nil, _user = me)).to eq '/my/name/is/joel'
    end

    it 'returns another path' do
      you = build_stubbed(:user, name: 'carl')
      described_class.user_path = ->(user) { "/wow/so/#{user.name}" }
      expect(described_class.user_path(_view_context = nil, _user = you)).to eq '/wow/so/carl'
    end

    it 'executes in the given context' do
      described_class.user_path = ->(_user) { reverse }
      expect(described_class.user_path(_view_context = 'abc', _user = nil)).to eq 'cba'
    end

    it 'returns nil' do
      me = build_stubbed(:user, name: 'joel')
      described_class.user_path = ->(_user) { nil }
      expect(described_class.user_path(_view_context = nil, _user = me)).to be_nil
    end
  end

  context '.user_display_name_method', thredded_reset: %i[@user_display_name_method @user_name_column] do
    it 'when nil it returns the same value as name method' do
      described_class.user_name_column = :name
      described_class.user_display_name_method = nil
      expect(described_class.user_display_name_method).to eq(:name)
    end

    it 'returns value it was set' do
      described_class.user_display_name_method = :to_s
      expect(described_class.user_display_name_method).to eq(:to_s)
    end
  end

  context '.messageboards_order', thredded_reset: [:@messageboards_order] do
    specify 'default' do
      expect(described_class.messageboards_order).to eq(:position)
    end
    describe 'valid values' do
      %i[position topics_count_desc last_post_at_desc].each do |valid_value|
        it ":#{valid_value}" do
          described_class.messageboards_order = valid_value
          expect(described_class.messageboards_order).to eq(valid_value)
        end
      end
    end

    it 'raises error if assigned to invalid value' do
      [nil, :created_at_asc].each do |invalid_value|
        expect { described_class.messageboards_order = invalid_value }
          .to raise_error(/unexpected value for /i)
      end
    end
  end

  describe described_class, '.notifiers', thredded_reset: [:@notifiers] do
    specify 'default' do
      notifiers = described_class.notifiers
      expect(notifiers.length).to be(1)
      expect(notifiers).to include(an_instance_of(Thredded::EmailNotifier))
      expect(notifiers.first).to equal(described_class.notifiers.first) # ie it returns same object -- not another one
    end

    specify 'can assign to new notifier instance' do
      mock = MockNotifier.new
      described_class.notifiers = [mock]
      expect(described_class.notifiers).to eq([mock])
    end

    specify 'problematic notifier fails early' do
      expect { described_class.notifiers = ['badly-specified'] }.to raise_error(/notifier/i)
    end
  end
end
