# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe Badge do
    it 'has a unique title' do
      expect{ create(:badge, title: 'unique') }.not_to raise_error
      expect{ create(:badge, title: 'unique') }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'raises Thredded::Errors::BadgeNotFound when badge is not found' do
      badge = create(:badge)
      expect{ Badge.find!(badge.id) }.not_to raise_error
      expect{ Badge.find!(99) }.to raise_error(Thredded::Errors::BadgeNotFound)
    end
  end

  describe UserDetail, 'active storage' do
    it 'attaches the uploaded file' do
      file = fixture_file_upload(Rails.root.join('public', 'apple-touch-icon.png'), 'image/png')
      badge = create(:badge, title: 'unique')
      expect(badge.badge_icon).not_to be_attached

      badge.badge_icon.attach(file)
      expect(badge.badge_icon).to be_attached
    end
  end
end
