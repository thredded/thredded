require 'spec_helper'

module Thredded
  describe PostNotification, 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:post) }
  end

  describe PostNotification, 'associations' do
    it { should belong_to(:post) }
  end
end
