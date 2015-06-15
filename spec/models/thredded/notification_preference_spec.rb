require 'spec_helper'

module Thredded
  describe NotificationPreference, 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:messageboard_id) }
  end
  describe NotificationPreference do
    it { should belong_to(:user) }
    it { should belong_to(:messageboard) }
    it { should have_db_column(:notify_on_mention) }
    it { should have_db_column(:notify_on_message) }
  end
end
