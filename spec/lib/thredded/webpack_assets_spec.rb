# frozen_string_literal: true

require 'spec_helper'

describe Thredded::WebpackAssets do
  it 'finds all javascripts' do
    expect { described_class.javascripts }.not_to raise_error
  end
end
