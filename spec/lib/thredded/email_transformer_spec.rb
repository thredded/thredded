# frozen_string_literal: true

require 'spec_helper'

describe Thredded::EmailTransformer do
  it 'smoke test' do
    src = File.read(File.join(File.dirname(__FILE__), 'email.html'))
    expect { Thredded::EmailTransformer.call(Nokogiri::HTML::Document.parse(src)) }.to_not raise_error
  end
end
