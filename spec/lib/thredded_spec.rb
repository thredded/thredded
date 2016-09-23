# frozen_string_literal: true
require 'spec_helper'

describe Thredded, '.user_path', thredded_reset: [:@@user_path] do
  it 'returns one path' do
    me = build_stubbed(:user, name: 'joel')
    Thredded.user_path = ->(user) { "/my/name/is/#{user.name}" }
    expect(Thredded.user_path(_view_context = nil, _user = me)).to eq '/my/name/is/joel'
  end

  it 'returns another path' do
    you = build_stubbed(:user, name: 'carl')
    Thredded.user_path = ->(user) { "/wow/so/#{user.name}" }
    expect(Thredded.user_path(_view_context = nil, _user = you)).to eq '/wow/so/carl'
  end

  it 'executes in the given context' do
    Thredded.user_path = ->(_user) { reverse }
    expect(Thredded.user_path(_view_context = 'abc', _user = nil)).to eq 'cba'
  end
end

describe Thredded, '.user_display_name_method', thredded_reset: [:@@user_display_name_method, :@@user_name_column] do
  it 'when nil it returns the same value as name method' do
    Thredded.user_name_column = :name
    Thredded.user_display_name_method = nil
    expect(Thredded.user_display_name_method).to eq(:name)
  end

  it 'returns value it was set' do
    Thredded.user_display_name_method = :to_s
    expect(Thredded.user_display_name_method).to eq(:to_s)
  end
end

describe Thredded, '.messageboards_order', thredded_reset: [:@@messageboards_order] do
  specify 'default' do
    expect(Thredded.messageboards_order).to eq(:position)
  end
  describe 'valid values' do
    [:position, :topics_count_desc, :last_post_at_desc].each do |valid_value|
      it ":#{valid_value}" do
        Thredded.messageboards_order = valid_value
        expect(Thredded.messageboards_order).to eq(valid_value)
      end
    end
  end

  it 'raises error if assigned to invalid value' do
    [nil, :created_at_asc].each do |invalid_value|
      expect { Thredded.messageboards_order = invalid_value }
        .to raise_error(/unexpected value for /i)
    end
  end
end
