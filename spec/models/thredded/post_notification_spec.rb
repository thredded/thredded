require 'spec_helper'

describe PostNotification do
  it { should belong_to(:post) }
end
