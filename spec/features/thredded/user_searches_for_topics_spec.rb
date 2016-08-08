# frozen_string_literal: true
require 'spec_helper'

feature 'User searching topics' do
  title = 'Rando thread'

  # On MySQL, a transaction has to complete before the full text search index is updated
  before :all do
    messageboard = create(:messageboard)
    create(:topic, title: title, messageboard: messageboard)
    create_list(:topic, 2, messageboard: messageboard)
    @topics = PageObject::Topics.new(messageboard)
  end

  after :all do
    DatabaseCleaner.clean_with(:truncation)
  end

  search_and_expect_found = lambda do
    @topics.search_for(title)
    expect(page).to have_content(I18n.t('thredded.topics.search.results_message', query: "'#{title}'"))
    expect(@topics.normal_topics.size).to eq(1)
    expect(@topics).to have_topic_titled(title)
  end

  scenario 'in a messageboard' do
    @topics.visit_style_guide
    instance_exec(&search_and_expect_found)
  end

  scenario 'globally' do
    visit thredded.root_path
    instance_exec(&search_and_expect_found)
  end
end
