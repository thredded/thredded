require 'spec_helper'

feature 'User starring a topic' do
  scenario 'sees a list of unstarred topics' do
    topics = three_topics
    topics.visit_index

    expect(topics).to have(0).starred_topics
  end

  scenario 'views an unstarred topic' do
    topics = three_topics
    topic = topics.visit_latest_topic

    expect(topic).to be_able_to_star
    expect(topic).to be_rated_as(0)
  end

  scenario 'stars a topic' do
    topics = three_topics
    topic = topics.visit_latest_topic
    topic.star_topic

    expect(topic).to be_rated_as(1)
    expect(topic).to be_able_to_unstar

    topics.visit_index

    expect(topics).to have(1).starred_topics
  end

  scenario 'unstars a topic' do
    topics = three_topics
    topics.visit_latest_topic
    topic.star_topic
    topic.unstar_topic

    expect(topic).to be_able_to_star
    expect(topic).to be_rated_as(0)

    topics.visit_index

    expect(topics).to have(0).starred_topics
  end

  def three_topics
    @three_topics ||= begin
      messageboard = create(:messageboard)
      create_list(:topic, 3, messageboard: messageboard)
      PageObject::Topics.new(messageboard)
    end
  end
end
