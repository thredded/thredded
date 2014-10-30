require 'spec_helper'

module Thredded
  describe UserPreference, 'associations' do
    it { should belong_to(:user) }
  end

  describe UserPreference, 'validations' do
    it { should validate_presence_of(:user_id) }
  end

  describe UserPreference, 'defaults' do
    it 'for timezone and filter' do
      pref = UserPreference.new

      expect(pref.time_zone).to eq 'Eastern Time (US & Canada)'
    end
  end
end
