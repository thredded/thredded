# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Thredded::PostModerationRecord do
  it 'empty preload_first_topic_post' do
    expect { described_class.preload_first_topic_post.to_a }.not_to raise_error
  end
end
