require 'spec_helper'

module Thredded
  describe Preference do
    it { should belong_to :user }
    it { should belong_to :messageboard }
    it { should have_db_column(:notify_on_mention) }
    it { should have_db_column(:notify_on_message) }
  end
end
