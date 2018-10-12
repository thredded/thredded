# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'User sends a new private topic' do
  it 'with title, recipient and content' do
    PageObject::User.new(create(:user, name: 'joel')).log_in
    private_topic = PageObject::PrivateTopics.new('A new message')
    private_topic.create_private_topic
    private_topic.visit_private_topic_list
    expect(private_topic).to be_on_private_list
  end

  describe 'autocompletion in textbox', js: true do
    let(:user_names) { ['Barbara Fleischman', 'Barb', 'Barbara', 'Eric'] }
    let!(:users) { user_names.map { |n| create(:user, name: n) } }

    before do
      PageObject::User.new(create(:user, name: 'joel')).log_in
    end

    it 'shows dropdown' do
      private_topic = PageObject::PrivateTopics.new('A new message')
      click_on 'Private Messages'
      click_on 'Start your first private conversation'

      fill_in I18n.t('thredded.private_topics.form.title_label'), with: private_topic.private_title
      find(:css, '[name="private_topic[user_names]"]').hover
      find(:css, '[name="private_topic[user_names]"]').click
      find(:css, '[name="private_topic[user_names]"]').send_keys('Bar')
      expect(page).to have_css('ul.thredded--textcomplete-dropdown li', count: 3)
      find(:css, '[name="private_topic[user_names]"]').send_keys('b')
      expect(page).to have_css('ul.thredded--textcomplete-dropdown li', count: 3)
      find(:css, '[name="private_topic[user_names]"]').send_keys('ara')
      expect(page).to have_css('ul.thredded--textcomplete-dropdown li', count: 2)
      find(:css, '[name="private_topic[user_names]"]').send_keys(' Fleis')
      expect(page).to have_css('ul.thredded--textcomplete-dropdown li', count: 1)
      find(:css, '[name="private_topic[user_names]"]').send_keys("\n")
      expect(find(:css, '[name="private_topic[user_names]"]').value).to eq('Barbara Fleischman, ')
    end
  end
end
