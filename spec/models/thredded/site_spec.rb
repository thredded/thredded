require 'spec_helper'

describe Site do

  subject { create(:site) }

  it { should have_many(:messageboards) }
  it { should belong_to(:user) }
  it { should validate_uniqueness_of(:subdomain) }
  it { should validate_uniqueness_of(:cname_alias) }
  it { should validate_presence_of(:permission) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }

end
