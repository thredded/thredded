require 'spec_helper'

feature 'User viewing topics' do
  scenario 'sees a list of topics' do
    topics = three_topics
    topics.visit_index

    expect(topics).to have(3).normal_topics
  end

  scenario 'sees a locked topic' do
    topics = one_locked_two_regular_topics
    topics.visit_index

    expect(topics).to have(1).locked_topic
    expect(topics).to have(2).normal_topics
  end

  scenario 'sees a sticky topic' do
    topics = one_stuck_two_regular_topics
    topics.visit_index

    expect(topics).to have(1).stuck_topic
    expect(topics).to have(2).normal_topics
  end

  def three_topics
    messageboard = create(:messageboard)
    create_list(:topic, 3, messageboard: messageboard)
    PageObject::Topic.new(messageboard)
  end

  def one_locked_two_regular_topics
    messageboard = create(:messageboard)
    create_list(:topic, 2, messageboard: messageboard)
    create(:topic, :locked, messageboard: messageboard)
    PageObject::Topic.new(messageboard)
  end

  def one_stuck_two_regular_topics
    messageboard = create(:messageboard)
    create_list(:topic, 2, messageboard: messageboard)
    create(:topic, :sticky, messageboard: messageboard)
    PageObject::Topic.new(messageboard)
  end
end
