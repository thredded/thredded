require 'spec_helper'

feature 'User starring a topic' do
  before do
    pending 'Initial specs for review'

    @topics = three_topics
  end

  scenario 'sees a list of unstarred topics' do
    @topics.visit_index

    expect(@topics).to have(0).starred_topics
  end

  scenario 'views an unstarred topic' do
    @topics.visit_latest_topic

    expect(page).to have_link('Star this topic')

    expect(page).to_not have_stars
  end

  scenario 'stars a topic' do
    @topics.visit_latest_topic

    click_on 'Star this topic'

    expect(page).to have_content('Star rating: 1')
    expect(page).to have_link('Unstar this topic')

    expect(page).to_not have_link('Star this topic')

    @topics.visit_index

    expect(@topics).to have(1).starred_topics
  end

  scenario 'unstars a topic' do
    @topics.visit_latest_topic

    click_on 'Star this topic'

    click_on 'Unstar this topic'

    expect(page).to have_link('Star this topic')

    expect(page).to_not have_stars

    @topics.visit_index

    expect(@topics).to have(0).starred_topics
  end

  def three_topics
    messageboard = create(:messageboard)
    create_list(:topic, 3, messageboard: messageboard)
    PageObject::Topics.new(messageboard)
  end
end
