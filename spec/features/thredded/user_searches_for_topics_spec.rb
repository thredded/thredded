# frozen_string_literal: true

require 'spec_helper'

feature 'User searching topics' do
  title = 'Rando thread'

  # On MySQL, a transaction has to complete before the full text search index is updated
  before :all do
    @messageboard = create(:messageboard)
    create(:topic, title: title, messageboard: @messageboard)
    create_list(:topic, 2, messageboard: @messageboard)
    @topics = PageObject::Topics.new(@messageboard)
  end

  after :all do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'in a messageboard' do
    @topics.visit_style_guide
    @topics.search_for(title)
    expect(page.source).to(
      include(I18n.t('thredded.topics.search.results_in_messageboard_message_html',
                     query: title, messageboard: @messageboard.name))
    )
    expect(@topics.normal_topics.size).to eq(1)
    expect(@topics).to have_topic_titled(title)
  end

  scenario 'globally' do
    visit thredded.root_path
    @topics.search_for(title)
    expect(page.source).to include(I18n.t('thredded.topics.search.results_message_html', query: title))
    expect(@topics.normal_topics.size).to eq(1)
    expect(@topics).to have_topic_titled(title)
  end
end
