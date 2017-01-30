# frozen_string_literal: true
require 'spec_helper'

feature 'User creates new topic' do
  scenario 'with title and content', js: true do
    topic = new_topic

    topic.fill_topic_form('Hello *world*!')
    expect(topic.preview_html).to eq("<p>Hello <em>world</em>!</p>\n")
    topic.submit

    expect(topic).to be_listed
    expect(topic).to be_read

    topic.visit_latest_topic
    expect(topic).to be_displayed
  end

  scenario 'and sees no categories in the form when none exist' do
    topic_form = new_topic
    topic_form.visit_form

    expect(topic_form).not_to have_category_input
  end

  scenario 'with a category' do
    topic_form = new_topic_with_categories
    topic_form.visit_form

    expect(topic_form).to have_category_input
  end

  scenario 'and sees no locked or sticky checkboxes' do
    topic_form = new_topic
    topic_form.visit_form

    expect(topic_form).not_to have_a_locked_checkbox
    expect(topic_form).not_to have_a_sticky_checkbox
  end

  context 'as an admin' do
    scenario 'and can make it locked or sticky' do
      topic_form = new_topic_as_an_admin
      topic_form.visit_form

      expect(topic_form).to have_a_locked_checkbox
      expect(topic_form).to have_a_sticky_checkbox
    end

    scenario 'and confirms new topic is locked and sticky' do
      topic = new_topic_as_an_admin
      topic.visit_form
      topic.with_title('I have an opinion!')
      topic.with_content('Belgian IPAs are the best')
      topic.make_locked
      topic.make_sticky
      topic.select_category('beer')
      topic.submit

      topic.visit_latest_topic

      expect(topic).to be_locked
      expect(topic).to be_stuck
      expect(topic).to be_categorized('beer')
      expect(topic).to have_the_title_and_content
    end
  end

  def new_topic
    sign_in
    messageboard = create(:messageboard)
    PageObject::Topics.new(messageboard)
  end

  def new_topic_with_categories
    sign_in
    messageboard = create(:messageboard)
    create(:category, :beer, messageboard: messageboard)
    PageObject::Topics.new(messageboard)
  end

  def new_topic_as_an_admin
    messageboard = create(:messageboard)
    create(:category, :beer, messageboard: messageboard)
    sign_in_as_admin
    PageObject::Topics.new(messageboard)
  end

  def sign_in
    PageObject::User.new(create(:user, name: 'joel')).log_in
  end

  def sign_in_as_admin
    PageObject::User.new(create(:user, :admin, name: 'joel-admin')).log_in
  end
end
