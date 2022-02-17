# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'User viewing topics' do
  it 'sees a list of topics' do
    topics = three_topics
    topics.visit_index

    expect(topics.normal_topics.size).to eq(3)
  end

  it 'sees a locked topic' do
    topics = one_locked_two_regular_topics
    topics.visit_index

    expect(topics.locked_topics.size).to eq(1)
    expect(topics.normal_topics.size).to eq(2)
  end

  it 'sees a sticky topic' do
    topics = one_stuck_two_regular_topics
    topics.visit_index

    expect(topics.stuck_topics.size).to eq(1)
    expect(topics.normal_topics.size).to eq(2)
    expect(topics).to have_sticky_divider
  end

  def three_topics
    messageboard = create(:messageboard)
    create_list(:topic, 3, messageboard: messageboard)
    PageObject::Topics.new(messageboard)
  end

  def one_locked_two_regular_topics
    messageboard = create(:messageboard)
    create_list(:topic, 2, messageboard: messageboard)
    create(:topic, :locked, messageboard: messageboard)
    PageObject::Topics.new(messageboard)
  end

  def one_stuck_two_regular_topics
    messageboard = create(:messageboard)
    create_list(:topic, 2, messageboard: messageboard)
    create(:topic, :sticky, messageboard: messageboard)
    PageObject::Topics.new(messageboard)
  end
end
