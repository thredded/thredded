# frozen_string_literal: true
require 'spec_helper'

feature 'User visits root' do
  [
    ['Application layout', 'application'],
    ['Standalone layout', 'thredded/application']
  ].each do |(desc, layout)|
    context desc do
      around do |ex|
        was = Thredded.layout
        begin
          Thredded.layout = layout
          ex.call
        ensure
          Thredded.layout = was
        end
      end

      scenario 'sees a page when anonymous' do
        visit thredded.root_path
        expect(page).to have_content(I18n.t('thredded.nav.all_messageboards'))
      end

      scenario 'sees a page when signed in' do
        PageObject::User.new(create(:user)).log_in
        visit thredded.root_path
        expect(page).to have_content(I18n.t('thredded.nav.all_messageboards'))
      end
    end
  end
end
