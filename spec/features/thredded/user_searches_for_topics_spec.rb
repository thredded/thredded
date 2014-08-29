require 'spec_helper'

feature 'User searching topics' do
  scenario 'sees a list of found topics' do
    topics = three_topics
    topics.visit_index
    topics.search_for('Rando thread')

    expect(page).to have_content('Results for "Rando thread"')
    expect(topics).to have(1).normal_topics
    expect(topics).to have_topic_titled('Rando thread')
  end

  def three_topics
    messageboard = create(:messageboard)
    create(:topic, title: 'Rando thread', messageboard: messageboard)
    create_list(:topic, 2, messageboard: messageboard)
    PageObject::Topics.new(messageboard)
  end
end
