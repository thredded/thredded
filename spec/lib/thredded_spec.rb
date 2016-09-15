# frozen_string_literal: true
require 'spec_helper'

describe Thredded, '.user_path' do
  around do |ex|
    begin
      user_path_was = Thredded.class_variable_get(:@@user_path)
      ex.call
    ensure
      Thredded.user_path = user_path_was
    end
  end

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
