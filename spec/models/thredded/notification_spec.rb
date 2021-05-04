# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe Notification do
    it 'name must be present' do
      expect{ create(:notification, name: 'present') }.not_to raise_error
      expect{ create(:notification, name: '') }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'raises Thredded::Errors::NotificationNotFound when notification is not found' do
      notification = create(:notification)
      expect{ Notification.find!(notification.id) }.not_to raise_error
      expect{ Notification.find!(99) }.to raise_error(Thredded::Errors::NotificationNotFound)
    end
  end
end
