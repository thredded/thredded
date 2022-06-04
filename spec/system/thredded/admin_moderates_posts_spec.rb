# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'Moderating posts' do
  context 'as an admin' do
    let(:admin) { PageObject::User.new(create(:user, name: 'joe-admin', admin: true)) }

    let!(:topic) { create(:topic) }
    let!(:post_1) { create(:post, postable: topic) }
    let!(:post_2) { create(:post, postable: topic) }
    let!(:post_3) { create(:post, postable: topic) }

    it 'can approve, block and review posts' do
      admin.log_in
      click_on 'Moderation' # visit "/thredded/admin/moderation"
      expect(page).to have_content(topic.title)
      approve_post(post_1)
      block_post(post_2)
      click_on 'History'

      expect(page).to have_selector(dom_id_as_selector(post_1))
      expect(page).to have_selector(dom_id_as_selector(post_2))
      expect(page).not_to have_selector(dom_id_as_selector(post_3))
    end
  end

  def approve_post(post)
    expect(page).to have_selector(dom_id_as_selector(post))
    within dom_id_as_selector(post) do
      click_on 'Approve'
    end
    within '.thredded--moderated-notice' do
      within dom_id_as_selector(post) do
        expect(page).to have_content('Post approved by')
      end
    end
  end

  def block_post(post)
    expect(page).to have_selector(dom_id_as_selector(post))
    within dom_id_as_selector(post) do
      click_on 'Block'
    end
    within '.thredded--moderated-notice' do
      within dom_id_as_selector(post) do
        expect(page).to have_content('Post blocked by')
      end
    end
  end
end
