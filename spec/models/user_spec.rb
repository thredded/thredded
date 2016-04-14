# frozen_string_literal: true
require 'spec_helper'

describe User, '.to_s' do
  it 'returns the username string' do
    user = create(:user, name: 'Joseph')

    expect(user.to_s).to eq 'Joseph'
  end
end
