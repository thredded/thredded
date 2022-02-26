# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'User creates new topic' do
  it 'with title and content', js: true do
    topic = new_topic

    topic.fill_topic_form('Hello *world*!')
    within topic.preview_selector do
      expect(page.html).to include("<p>Hello <em>world</em>!</p>\n")
    end
    topic.submit

    expect(topic).to be_listed
    expect(topic).to be_read

    topic.visit_latest_topic
    expect(topic).to be_displayed
  end

  it 'rendering preview multiple times', js: true do
    topic = new_topic
    topic.visit_form
    topic.fill_topic_form('Hello *world*!')
    within topic.preview_selector do
      expect(page.html).to include("<p>Hello <em>world</em>!</p>\n")
    end
    topic.fill_topic_form('Strange `code`')
    within topic.preview_selector do
      expect(page.html).to include("<p>Strange <code>code</code></p>\n")
    end
    topic.fill_topic_form('Something **else**')
    within topic.preview_selector do
      expect(page.html).to include("<p>Something <strong>else</strong></p>\n")
    end
  end

  it 'with prefilled title and content which is automatically previewed', js: true do
    topic = new_topic
    topic.visit_form(topic: { title: 'Hello title', content: 'Hello *world*!' })
    expect(page).to have_field('Title', with: 'Hello title')
    expect(page).to have_field('Content', with: 'Hello *world*!')
    within topic.preview_selector do
      expect(page.html).to include("<p>Hello <em>world</em>!</p>\n")
    end
  end

  it 'and sees no categories in the form when none exist' do
    topic_form = new_topic
    topic_form.visit_form

    expect(topic_form).not_to have_category_input
  end

  it 'with a category' do
    topic_form = new_topic_with_categories
    topic_form.visit_form

    expect(topic_form).to have_category_input
  end

  it 'and sees no locked or sticky checkboxes' do
    topic_form = new_topic
    topic_form.visit_form

    expect(topic_form).not_to have_a_locked_checkbox
    expect(topic_form).not_to have_a_sticky_checkbox
  end

  it 'redirects to a specific next_page (topic)' do
    topic = new_topic
    topic.visit_form(next_page: 'topic')
    topic.with_title('Sample thread title')
    topic.with_content('Hello *world*!')
    topic.submit
    expect(page).to have_current_path(topic.latest_topic_path)
  end

  context 'as an admin' do
    it 'and can make it locked or sticky' do
      topic_form = new_topic_as_an_admin
      topic_form.visit_form

      expect(topic_form).to have_a_locked_checkbox
      expect(topic_form).to have_a_sticky_checkbox
    end

    it 'and confirms new topic is locked and sticky' do
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
