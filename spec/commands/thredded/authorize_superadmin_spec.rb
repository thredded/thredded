require 'spec_helper'

module Thredded
  describe AuthorizeSuperadmin, '#run' do
    it 'makes that user a superadmin' do
      user = create(:user, name: 'joel')
      AuthorizeSuperadmin.new('joel').run

      expect(user.thredded_user_detail.superadmin).to eq true
    end

    it 'updates the user to be a superadmin' do
      user = create(:user, :superadmin, name: 'joel')
      AuthorizeSuperadmin.new('joel').run

      expect(user.thredded_user_detail.superadmin).to eq true
    end

    it 'fails with the right exception if a user is not found' do
      expect { AuthorizeSuperadmin.new('carl').run }
        .to raise_error(Thredded::Errors::UserNotFound)
    end
  end
end
