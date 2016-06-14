# frozen_string_literal: true
require 'spec_helper'

feature 'User searching private topics' do
  title = 'Rando thread'

  # On MySQL, a transaction has to complete before the full text search index is updated
  before :all do
    user.log_in
    create(:private_topic, title: title, user: @user, users: [@user, them], posts: build_list(:private_post, 1))
    create_list(:private_topic, 2, user: @user)

    @private_topics = PageObject::PrivateTopics.new(title)
  end

  after :all do
    Thredded::PrivateTopic.destroy_all
  end

  search_and_expect_found = lambda do
    @private_topics.search_for(title)
    expect(page).to have_content(I18n.t('thredded.topics.search.results_message', query: "'#{title}'"))
    expect(@private_topics.private_topics.size).to eq(1)
    expect(@private_topics).to have_topic_titled(title)
  end

  scenario 'from index and within a topic' do
    @private_topics.visit_index
    instance_exec(&search_and_expect_found)

    @private_topics.view_private_topic
    instance_exec(&search_and_expect_found)
  end

  def user
    @user ||= create(:user)
    PageObject::User.new(@user)
  end

  def them
    create(:user, name: 'them')
  end
end
