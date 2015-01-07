require 'spec_helper'

feature 'User searching topics' do
  # On MySQL, a transaction has to complete before the full text search index is updated
  before :all do
    messageboard = create(:messageboard)
    create(:topic, title: 'Rando thread', messageboard: messageboard)
    create_list(:topic, 2, messageboard: messageboard)
    @three_topics = PageObject::Topics.new(messageboard)
  end

  after :all do
    @three_topics.messageboard.destroy
  end

  scenario 'sees a list of found topics',
    skip: ('Indexed full text search on InnoDB tables requires MySQL v5.6.4+' unless Thredded.supports_fulltext_search?) do

    topics = @three_topics
    topics.visit_index
    topics.search_for('Rando thread')

    expect(page).to have_content('Results for "Rando thread"')
    expect(topics.normal_topics.size).to eq(1)
    expect(topics).to have_topic_titled('Rando thread')
  end
end
