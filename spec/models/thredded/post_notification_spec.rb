require 'spec_helper'

module Thredded
  describe PostNotification do
    it { should belong_to(:post) }
  end
end
