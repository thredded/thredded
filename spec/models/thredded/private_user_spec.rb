require 'spec_helper'

module Thredded
  describe PrivateUser do
    it { should belong_to(:private_topic) }
    it { should belong_to(:user) }
  end
end
