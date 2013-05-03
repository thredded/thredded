require 'spec_helper'

describe Role do

  before(:each) do
    @admin_user = create(:user, :email => "role@admin.com", :name => "adminUser")
    @admin = create(:role_admin)
    @messageboard = @admin.messageboard
    @admin_user.roles << @admin
    @admin_user.roles.reload
  end

  describe "#.for(messageboard)" do
    it "filters down roles only for this messagebaord" do
      Role.for(@messageboard).should include(@admin)
    end
  end

  describe "#.as(role)" do
    it "filters down roles only for this particular role" do
      Role.as('admin').should include(@admin)
    end
  end

  describe "#for(messageboard).as(role)" do
    it "filters down roles for this messageboard" do
      Role.for(@messageboard).as('admin').should include(@admin)
    end
  end

end
